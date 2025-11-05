#!/usr/bin/env python3
import os
import sys
import shlex
import subprocess

IMAGE = os.environ.get("VIM_DOCKER_IMAGE", "vim-ttsiodras:latest")
RESTRICTED_NET = "restricted_net"

def real(p: str) -> str:
    """Expand ~ and resolve symlinks to a canonical absolute path."""
    return os.path.realpath(os.path.expanduser(p))

def is_option(arg: str) -> bool:
    # Vim options often start with '-' (e.g., -u NONE) or '+' (e.g., +G, +999)
    return arg.startswith("-") or arg.startswith("+")

def collect_mount_dirs(args):
    """
    For each non-option arg that points to an existing file/dir,
    add its directory (or itself, if a dir) to the mount set.
    Always include the current working directory.
    """
    mounts = set()
    # Always mount the real PWD so relative paths work
    mounts.add(real(os.getcwd()))

    for a in args:
        if is_option(a):
            continue
        expanded = os.path.expanduser(a)
        # If it exists, resolve to real path and mount its directory (or itself if it's a dir)
        if os.path.exists(expanded):
            rp = os.path.realpath(expanded)
            mdir = rp if os.path.isdir(rp) else os.path.dirname(rp)
            if mdir:
                mounts.add(mdir)
    return dedupe_subpaths(mounts)

def dedupe_subpaths(paths):
    """
    Remove redundant subpaths (keep the shortest parent when another path lies under it).
    """
    norm = sorted({p.rstrip("/") or "/" for p in paths}, key=lambda x: (x.count("/"), len(x)))
    kept = []
    for p in norm:
        if not any(p != k and p.startswith(k + "/") for k in kept):
            kept.append(p)
    return kept

def build_vim_args(raw_args):
    """
    Build the argument list to pass to vim inside the container:
    - keep options (+/-) verbatim
    - for paths, pass canonical absolute paths so they match mounted locations
    """
    out = []
    for a in raw_args:
        if is_option(a):
            out.append(a)
        else:
            expanded = os.path.expanduser(a)
            if os.path.exists(expanded):
                out.append(os.path.realpath(expanded))
            else:
                # Non-existent paths: user said this isn't their use case; leave as-is
                out.append(a)
    return out

def make_docker_network():
    for line in os.popen("docker network ls"):
        if f"{RESTRICTED_NET}" in line:
            break
    else:
        os.system(
            "docker network create "
            "--driver bridge "
            "--subnet 172.30.0.0/24 "
            f"--opt com.docker.network.bridge.name={RESTRICTED_NET} "
            f"{RESTRICTED_NET}")

def main():
    # We'll isolate everything, expect 172.
    make_docker_network()

    raw_args = sys.argv[1:]

    # Figure out volumes to mount
    mount_dirs = collect_mount_dirs(raw_args)

    # Build docker run cmd
    docker_cmd = [
        "docker", "run", "--rm", "-it",
        "--network=none",

        # Or, if you need access to localhost-provided services, you make a hole in the restricted_net:
        #
        # docker network create \
        #    --driver bridge \
        #    --subnet 172.30.0.0/24 \
        #    --opt com.docker.network.bridge.name=restricted_net \
        #    restricted_net
        #
        # sudo iptables -N RESTRICTED_NET 2>/dev/null || true
        # sudo iptables -F RESTRICTED_NET
        # sudo iptables -A RESTRICTED_NET -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        # sudo iptables -A RESTRICTED_NET -d 172.17.0.1 -j ACCEPT
        # sudo iptables -A RESTRICTED_NET -j DROP
        #
        # Attach the chain to Docker's global pre-container hook
        # (DOCKER-USER is evaluated for all container traffic)
        # sudo iptables -I DOCKER-USER -s 172.30.0.0/24 -j RESTRICTED_NET
        #
        # f"--network={RESTRICTED_NET}",
        # "--add-host", "someHOSTNAME:172.17.0.1",

        "-u", f"{os.getuid()}:{os.getgid()}",
    ]

    # Mount each discovered directory to the same absolute path in the container
    for d in mount_dirs:
        docker_cmd += ["-v", f"{d}:{d}"]
    docker_cmd += ['-v', f'{real("~/.vim/sessions")}:/home/user/.vim/sessions']

    # Working directory remains the real PWD so relative paths behave
    docker_cmd += ["-w", real(os.getcwd())]

    docker_cmd += [IMAGE]

    # Build the vim command line to execute inside the container.
    # Use /bin/bash -lc to allow our quoting and keep $TERM behavior etc.
    vim_args = build_vim_args(raw_args)
    vim_cmdline = "/home/user/bin.local/vim " + shlex.join(vim_args)
    docker_cmd += ["/bin/bash", "-lc", vim_cmdline]

    # Execute
    try:
        # Inherit the current environment (useful for TERM)
        subprocess.run(docker_cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"[myvim] docker run failed with exit code {e.returncode}", file=sys.stderr)
        sys.exit(e.returncode)

if __name__ == "__main__":
    main()
