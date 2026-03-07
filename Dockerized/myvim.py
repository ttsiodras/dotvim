#!/usr/bin/env python3
"""
Launch Vim inside a network-isolated Docker container, mounting only the
directories needed for the files being edited. X11 and optional local
services (e.g. llama.cpp) are tunnelled via socat through the restricted
bridge network defined in rc.local.vim.

Each user gets a thin per-user image (vim-ttsiodras:<username>) built on
top of a shared 'base' stage that holds all the heavy tooling. The per-user
layer only adds a matching useradd, so all users share the same underlying
Docker layer cache — disk and build time are paid once.

On first run the image is built automatically. Subsequent runs by the same
user skip the build entirely.
"""
import os
import pwd
import re
import sys
import shlex
import socket
import subprocess
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
RESTRICTED_NET = "restricted_net"


def _default_image() -> str:
    """Return the per-user image tag, e.g. 'vim-ttsiodras:alice'."""
    username = pwd.getpwuid(os.getuid()).pw_name
    return f"vim-ttsiodras:{username}"


IMAGE = os.environ.get("VIM_DOCKER_IMAGE", _default_image())


def real(p: str) -> str:
    """Expand ~ and resolve symlinks to a canonical absolute path."""
    return os.path.realpath(os.path.expanduser(p))


def get_mount_point_relative_to_home(p: str) -> str:
    """
    Return the topmost directory just below $HOME for the given path.
    For example, if the real path is $HOME/foo/bar/file, returns $HOME/foo.
    """
    expanded = os.path.expanduser(p)
    real_path = os.path.realpath(expanded)
    home = os.path.expanduser("~")
    if not real_path.startswith(home + os.sep):
        raise ValueError(
            f"Path {real_path} is not under HOME directory {home}")
    rel_path = os.path.relpath(real_path, home)
    first_component = rel_path.split(os.sep, maxsplit=1)[0]
    return os.path.join(home, first_component)


def get_mount_point_for_path(p: str) -> str:
    """
    Calculate the mount point for a path, accounting for '..' traversal.
    If the path contains '..', we mount from a higher level to preserve
    the relative structure.
    """
    try:
        return get_mount_point_relative_to_home(p)
    except Exception:  # pylint: disable=broad-exception-caught
        pass
    expanded = os.path.expanduser(p)
    real_path = os.path.realpath(expanded)
    parts = os.path.normpath(expanded).split(os.sep)
    dotdot_count = parts.count('..')
    mount_point = \
        os.path.dirname(real_path) \
        if os.path.isfile(real_path) \
        else real_path
    for _ in range(dotdot_count):
        mount_point = os.path.dirname(mount_point)
    return mount_point


def is_option(arg: str) -> bool:
    """Return True if arg looks like a Vim option ('-u NONE', '+G', etc.)."""
    # Vim options often start with '-' (e.g., -u NONE) or '+' (e.g., +G, +999)
    return arg.startswith("-") or arg.startswith("+")


def collect_mount_dirs(args: list[str]) -> list[str]:
    """
    For each non-option arg that points to an existing file/dir,
    add its directory (or itself, if a dir) to the mount set.
    Always include the current working directory.
    Note: non-existent paths are skipped intentionally — vim can create
    new files, and those paths don't need a mount point pre-established.
    """
    mounts: set[str] = set()
    mounts.add(real(os.getcwd()))
    for a in args:
        if is_option(a):
            continue
        expanded = os.path.expanduser(a)
        if os.path.exists(expanded):
            mdir = get_mount_point_for_path(a)
            if mdir:
                mounts.add(mdir)
    return dedupe_subpaths(mounts)


def dedupe_subpaths(paths: set[str]) -> list[str]:
    """
    Remove redundant subpaths (keep the shortest parent when another path
    lies under it).
    """
    norm = sorted(
        {
            p.rstrip("/") or "/"
            for p in paths
        }, key=lambda x: (x.count("/"), len(x)))
    kept: list[str] = []
    for p in norm:
        if not any(p != k and p.startswith(k + "/") for k in kept):
            kept.append(p)
    return kept


def build_vim_args(raw_args: list[str]) -> list[str]:
    """
    Build the argument list to pass to vim inside the container:
    - keep options (+/-) verbatim
    - for paths, pass canonical absolute paths
      (so they match mounted locations)
    """
    out: list[str] = []
    for a in raw_args:
        if is_option(a):
            out.append(a)
        else:
            expanded = os.path.realpath(os.path.expanduser(a))
            if os.path.exists(expanded):
                out.append(os.path.realpath(expanded))
            else:
                out.append(a)
    return out


def assert_docker_network_exists() -> None:
    """Check that the restricted_net Docker network exists; exit if not."""
    result = subprocess.run(
        ["docker", "network", "inspect", RESTRICTED_NET],
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        print(f"[x] The '{RESTRICTED_NET}' network does not exist. "
              f"Run {SCRIPT_DIR}/rc.local.vim")
        sys.exit(1)


def ensure_image_exists(image: str) -> None:
    """
    Build the per-user image if it doesn't already exist.
    The heavy 'base' stage is shared across all users via Docker's layer
    cache, so only the first ever build (for any user) is slow.
    """
    result = subprocess.run(
        ["docker", "image", "inspect", image],
        capture_output=True, check=False,
    )
    if result.returncode == 0:
        return
    print(f"[myvim] Image {image!r} not found — building (base layers "
          f"are cached if another user has built before)...")
    e = pwd.getpwuid(os.getuid())
    subprocess.run([
        "docker", "build",
        "--build-arg", f"USER_UID={e.pw_uid}",
        "--build-arg", f"USER_GID={e.pw_gid}",
        "--build-arg", f"USERNAME={e.pw_name}",
        "--target", "final",
        "-t", image,
        str(SCRIPT_DIR),
    ], check=True)


def is_listening(port: int, host: str = "127.0.0.1", timeout: int = 1) -> bool:
    """Return True if something is accepting TCP connections on host:port."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(timeout)
        try:
            s.connect((host, port))
            return True
        except (ConnectionRefusedError, socket.timeout):
            return False


def launch_socat_for_fwding(port: int) -> None:
    """
    Launch socat to tunnel traffic from inside the container (i.e. going
    to 172.17.0.1:port) to the corresponding listening port
    on the localhost I/F.
    """
    result = subprocess.run([
        'pgrep', '-f',
        f'socat.*{port}.*172.17.0.1.*TCP:localhost:{port}'
    ], capture_output=True, check=False)
    if result.returncode == 0:
        return
    # pylint: disable=consider-using-with
    subprocess.Popen(
        [
            'socat',
            f'TCP-LISTEN:{port},reuseaddr,fork,bind=172.17.0.1',
            f'TCP:localhost:{port}'
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        stdin=subprocess.DEVNULL,
        start_new_session=True)


def get_display_suffix(display: str) -> str:
    """
    Extract the display number suffix from a DISPLAY string like
    'localhost:10.0', returning ':10'.
    Raises ValueError if the format is not recognised.
    """
    m = re.match(r'^localhost(:\d+)\.\d+$', display)
    if not m:
        raise ValueError(f"Cannot parse display suffix from: {display!r}")
    return m.group(1)


def get_xauth_cookie(display: str) -> str:
    """
    Return the MIT-MAGIC-COOKIE-1 for the given DISPLAY using xauth.
    Raises subprocess.CalledProcessError / ValueError on failure.
    """
    result = subprocess.run(
        ['xauth', 'list', display],
        capture_output=True,
        text=True,
        check=True,
    )
    parts = result.stdout.strip().split()
    if len(parts) < 3:
        raise ValueError(
            f"Could not parse xauth output for display {display!r}: "
            f"{result.stdout!r}")
    return parts[2]


def setup_ssh_x11_forwarding(display: str) -> str:
    """
    Set up X11 auth for an SSH-forwarded display and launch socat.
    Returns the docker DISPLAY value to use (e.g. '172.17.0.1:10').
    Raises on failure — caller should handle and decide whether to abort.
    """
    suffix = get_display_suffix(display)
    docker_display = f'172.17.0.1{suffix}'

    # Remove stale magic cookie, if any
    subprocess.run(['xauth', 'remove', docker_display],
                   capture_output=True, check=False)

    cookie = get_xauth_cookie(display)

    subprocess.run(
        ['xauth', 'add', docker_display, 'MIT-MAGIC-COOKIE-1', cookie],
        check=True)
    print(f"Successfully added X11 auth for {docker_display}")

    port = 6000 + int(suffix[1:])
    launch_socat_for_fwding(port)

    return docker_display


def build_xauth_container_setup(cookie: str, suffix: str) -> list[str]:
    """
    Return the list of shell commands (as strings) that should run inside
    the container to install the X11 magic cookie before vim starts.
    These are joined with ';' by the caller.
    """
    hostname_unix = f'"$(hostname)/unix{suffix}"'
    hostname_bare = f'"$(hostname){suffix}"'
    docker_172 = f'172.17.0.1{suffix}'
    docker_172_unix = f'172.17.0.1/unix{suffix}'
    return [
        f'COOKIE={shlex.quote(cookie)}',
        'export PATH=/home/user/.venv/bin:/home/user/.local/node_modules/.bin'
        ':/home/user/node-v16.19.0-linux-x64/bin:/home/user/bin.local:$PATH',
        'export VIRTUAL_ENV=/home/user/.venv',
        '. /home/user/.venv/bin/activate',
        (
            'if [ -n "$COOKIE" ]; then '
            '  touch ~/.Xauthority; '
            f'  xauth add {hostname_unix}'
            ' MIT-MAGIC-COOKIE-1 "$COOKIE" 2>/dev/null; '
            f'  xauth add {hostname_bare}'
            ' MIT-MAGIC-COOKIE-1 "$COOKIE" 2>/dev/null; '
            f'  xauth add {docker_172}'
            ' MIT-MAGIC-COOKIE-1 "$COOKIE" 2>/dev/null; '
            f'  xauth add {docker_172_unix}'
            ' MIT-MAGIC-COOKIE-1 "$COOKIE" 2>/dev/null; '
            'fi'
        ),
    ]


def get_host_xauth_cookie(ssh_display: str | None) -> tuple[str, str]:
    """
    Return (cookie, suffix) for the current session.
    Uses xauth directly — no shell string interpolation.
    """
    if ssh_display:
        suffix = get_display_suffix(ssh_display)
        cookie = get_xauth_cookie(ssh_display)
        return cookie, suffix

    # Local display: find the first xauth entry for this hostname
    result = subprocess.run(
        ['xauth', 'list'],
        capture_output=True, text=True, check=False,
    )
    hostname = socket.gethostname()
    for line in result.stdout.splitlines():
        if hostname in line:
            parts = line.split()
            if len(parts) >= 3:
                # Extract suffix from "hostname:0" or "hostname/unix:0"
                display_field = parts[0]
                m = re.search(r'(:\d+)$', display_field)
                suffix = m.group(1) if m else ':0'
                return parts[2], suffix
    return '', ':0'


def build_docker_cmd(
    mount_dirs: list[str],
    display_env: str,
) -> list[str]:
    """
    Assemble the `docker run` argument list up to (but not including)
    the image name and the command to execute inside the container.
    """
    docker_cmd = [
        "docker", "run", "--rm", "-it",
        # Network isolation via a restricted bridge network.
        # See rc.local.vim for the iptables rules that enforce it.
        # The network allows outbound traffic only to 172.17.0.1 (the host's
        # docker0 interface), enabling optional local service access (e.g.
        # llama.cpp on :8012) while blocking all other egress.
        f"--network={RESTRICTED_NET}",
        "-u", f"{os.getuid()}:{os.getgid()}",
    ]

    for d in mount_dirs:
        docker_cmd += ["-v", f"{d}:{d}"]

    docker_cmd += ["-w", real(os.getcwd())]
    docker_cmd += ["-e", "SHELLCHECK_OPTS=-x"]

    # Mount the entire home tree so `:e path/to/file` works anywhere.
    # The container's HOME stays at /home/user (where all tooling lives);
    # the caller's real home is mounted at its real path for file access.
    home = str(Path.home())
    docker_cmd += ['-v', f'{home}:{home}']
    docker_cmd += ["-e", "HOME=/home/user"]

    # X11
    docker_cmd += ['-v', '/tmp/.X11-unix:/tmp/.X11-unix']
    docker_cmd += ["-e", f"XAUTHORITY=/home/user/.Xauthority"]
    docker_cmd += ["-e", display_env]

    return docker_cmd


def main(dry_run: bool = False) -> None:
    """Parse arguments, build the Docker command, and exec Vim in a container.
    """
    assert_docker_network_exists()
    ensure_image_exists(IMAGE)

    raw_args = sys.argv[1:]
    if raw_args and raw_args[0] == '--dry-run':
        dry_run = True
        raw_args = raw_args[1:]

    mount_dirs = collect_mount_dirs(raw_args)

    # --- X11 / display setup ---
    ssh_display = os.getenv("DISPLAY", "") if os.getenv("SSH_CLIENT") else None
    display_env = "DISPLAY"  # default: pass through as-is

    if ssh_display:
        try:
            suffix = get_display_suffix(ssh_display)
            docker_display = setup_ssh_x11_forwarding(ssh_display)
            display_env = f"DISPLAY={docker_display}"
        except (ValueError, subprocess.CalledProcessError) as e:
            print(f"[myvim] Warning: X11 forwarding setup failed: {e}",
                  file=sys.stderr)
            suffix = ':0'
    else:
        suffix = ':0'

    # llama.vim autocomplete
    if is_listening(8012):
        launch_socat_for_fwding(8012)

    docker_cmd = build_docker_cmd(mount_dirs, display_env)
    docker_cmd += [IMAGE]

    # --- Build the shell command to run inside the container ---
    # Get xauth cookie safely (no shell injection)
    try:
        cookie, suffix = get_host_xauth_cookie(ssh_display)
    except (ValueError, subprocess.CalledProcessError) as e:
        print(f"[myvim] Warning: could not retrieve xauth cookie: {e}",
              file=sys.stderr)
        cookie, suffix = '', ':0'

    container_setup = build_xauth_container_setup(cookie, suffix)
    vim_invocation = (
        '/home/user/bin.local/vim '
        + shlex.join(build_vim_args(raw_args))
    )
    container_cmd = ' ; '.join(container_setup) + ' ; ' + vim_invocation

    docker_cmd += ["/bin/bash", "-lc", container_cmd]

    if dry_run:
        print("docker command:")
        for i, part in enumerate(docker_cmd):
            print(f"  [{i:02d}] {part}")
        print("\nshell command inside container:")
        print(f"  {container_cmd}")
        return

    try:
        subprocess.run(docker_cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(
            f"[myvim] docker run failed with exit code {e.returncode}",
            file=sys.stderr)
        sys.exit(e.returncode)


if __name__ == "__main__":
    main()
