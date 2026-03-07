# ── Stage 1: compile vim ─────────────────────────────────────────────────────
FROM debian:12-slim AS builder
ENV DEBIAN_FRONTEND=noninteractive
RUN set -eux;                                                                                \
    if timeout 1 bash -c 'echo > /dev/tcp/172.17.0.1/3142' 2>/dev/null; then                 \
        echo 'Acquire::http::Proxy "http://172.17.0.1:3142";' > /etc/apt/apt.conf.d/01proxy; \
    else                                                                                     \
        echo 'No apt-cacher-ng detected, using direct HTTP';                                 \
    fi;                                                                                      \
    echo 'Acquire::http::Timeout "5";' > /etc/apt/apt.conf.d/99timeouts;                     \
    apt-get update && apt-get install -y locales ca-certificates wget
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
RUN apt-get install -y wget perl python3 libpython3-dev libperl-dev gcc-11 make \
    libncurses-dev libx11-dev libxmu-dev libxfixes-dev \
    && rm -rf /var/lib/apt/lists/*
RUN groupadd --gid 1000 user && \
    useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home user
USER user
WORKDIR /home/user
RUN wget -q -O- https://github.com/vim/vim/archive/refs/tags/v9.1.1382.tar.gz | tar -zxvf -
WORKDIR /home/user/vim-9.1.1382
RUN CC=gcc-11 ./configure \
    --enable-python3interp=dynamic \
    --enable-perlinterp=dynamic \
    --prefix=/home/user/local \
    --with-x
RUN make -j "$(nproc)"
RUN make install

# ── Stage 2: base — all tooling, NO user account ─────────────────────────────
# This stage is the shared cache. Every per-user final image is just one
# thin layer on top of this one. docker build will reuse all layers here
# across all users, so disk/time cost is paid only once.
FROM debian:12 AS base
ARG DEV_PKGS
ENV DEBIAN_FRONTEND=noninteractive
RUN set -eux;                                                                                \
    if timeout 1 bash -c 'echo > /dev/tcp/172.17.0.1/3142' 2>/dev/null; then                 \
        echo 'Acquire::http::Proxy "http://172.17.0.1:3142";' > /etc/apt/apt.conf.d/01proxy; \
    else                                                                                     \
        echo 'No apt-cacher-ng detected, using direct HTTP';                                 \
    fi;                                                                                      \
    echo 'Acquire::http::Timeout "5";' > /etc/apt/apt.conf.d/99timeouts;                     \
    apt-get update && apt-get install -y locales ca-certificates wget gnupg
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
RUN wget -q -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN echo 'deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-19 main' \
    > /etc/apt/sources.list.d/archive_uri-http_apt_llvm_org_bookworm_-bookworm.list
# Why the clang stuff? Language-aware autocompletion and navigation for C/C++.
# Why the fast grep-ers? Bindings to them (e.g. ":Ack").
# Why shellcheck? To watch over shell code.
# Why curl? To verify network isolation.
RUN apt-get install -y \
    clang-format-19 clangd-19 \
    python3-yaml git exuberant-ctags wget xz-utils libpython3.11 \
    libperl5.36 libncurses6 ca-certificates libx11-6 libsm6 \
    libxt6 ripgrep silversearcher-ag shellcheck curl make busybox-static \
    python3-venv ${DEV_PKGS} \
    && rm -rf /var/lib/apt/lists/*

# A fixed uid 1000 'user' account owns all the tooling baked into the image.
# The final stage adds the real caller's account on top of this one.
RUN groupadd --gid 1000 user && \
    useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home user

WORKDIR /usr/local/bin
RUN ln -s /home/user/node-v16.19.0-linux-x64/bin/node node
RUN ln -s /home/user/node-v16.19.0-linux-x64/bin/npm npm
RUN ln -s /home/user/node-v16.19.0-linux-x64/bin/npx npx
RUN busybox --list | while read app; do [ ! -e "$app" ] && ln -s $(which busybox) $app ; done
COPY pstree .
USER user

COPY --from=builder --chown=1000:1000 /home/user/local /home/user/local
WORKDIR /home/user
RUN git clone --recursive https://github.com/ttsiodras/dotvim .vim
RUN ln -s .vim/.vimrc
WORKDIR /home/user/.vim
RUN git submodule init
RUN git submodule update --init --recursive --force --remote
WORKDIR /home/user
RUN wget -q -O- https://nodejs.org/dist/v16.19.0/node-v16.19.0-linux-x64.tar.xz | tar -Jxvf -
RUN mkdir bin.local
RUN bash -c 'echo "export PATH=/home/user/.venv/bin:/home/user/.local/node_modules/.bin:/home/user/node-v16.19.0-linux-x64/bin:/home/user/bin.local:$PATH" > bin.local/vim'
RUN bash -c 'echo "/home/user/local/bin/vim \"\$@\"" >> bin.local/vim'
RUN chmod +x bin.local/vim
RUN ln -s /usr/bin/clangd-19 /home/user/bin.local/clangd
RUN bash -c 'echo "#!/bin/bash" > bin.local/clangd-mine'
RUN bash -c 'echo "exec /usr/bin/clangd-19 -header-insertion=never" > bin.local/clangd-mine'
RUN chmod +x bin.local/clangd-mine
RUN python3 -m venv .venv && \
    .venv/bin/pip install --upgrade pip && \
    .venv/bin/pip install pylint flake8 mypy
RUN cat >> .bashrc << 'EOF'
source /home/user/.venv/bin/activate
EOF
RUN cat >> .profile << 'EOF'
source /home/user/.venv/bin/activate
EOF
ENV PATH="/home/user/.venv/bin:$PATH"
RUN mkdir -p /home/user/.config/clangd
RUN bash -c 'echo -e "Diagnostics:\n  Suppress:\n    - builtin_definition\n" > /home/user/.config/clangd/config.yaml'
RUN /home/user/local/bin/vim -Nu /home/user/.vimrc -n -es -i NONE \
    +'silent! PlugInstall --sync' \
    +'qa!' < /dev/null
RUN /home/user/local/bin/vim -Nu /home/user/.vimrc -n -es -i NONE \
    +":runtime autoload/pathogen.vim" \
    +"call pathogen#helptags()" \
    +'qa!' < /dev/null
RUN /home/user/local/bin/vim -Nu /home/user/.vimrc -n -es -i NONE \
    +"CocInstall -sync coc-pyright" \
    +'qa!' < /dev/null
RUN bash -c 'npm install --prefix ~/.local yaml-language-server'

# ── Stage 3: final — one thin layer that adds the real user ──────────────────
# Built per-user via myvim.py (or manually). All heavy layers above are shared.
# Because the account matches the caller's uid/gid, file ownership, $HOME,
# CoC cache, viminfo, sessions etc. all work without any bind-mount tricks.
FROM base AS final
ARG USER_UID
ARG USER_GID
ARG USERNAME
USER root
# Remove the placeholder uid-1000 'user' account created in the base stage.
# If the caller's uid also happens to be 1000, without this we'd get a
# "UID is not unique" error. Without -r, userdel leaves /home/user intact.
#
# We point the new account's home at /home/user (--home-dir, --no-create-home)
# so that all the hardcoded /home/user paths baked into bin.local/vim, the
# venv, .vimrc symlink, CoC cache etc. keep working without any changes.
# chown makes the real user the owner of everything in there.
RUN userdel user 2>/dev/null || true && \
    groupdel user 2>/dev/null || true && \
    groupadd --gid ${USER_GID} ${USERNAME} 2>/dev/null || true && \
    useradd -u ${USER_UID} -g ${USER_GID} \
            -s /bin/bash \
            -d /home/user \
            -M \
            ${USERNAME} && \
    chown -R ${USER_UID}:${USER_GID} /home/user
USER ${USERNAME}
