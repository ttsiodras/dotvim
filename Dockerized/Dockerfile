FROM debian:12-slim AS builder

ARG DEV_PKGS

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y locales ca-certificates wget

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN apt-get install -y wget libpython3-dev libperl-dev gcc-11 g++-11 make libncurses-dev \
    && rm -rf /var/lib/apt/lists/*

ARG USER_UID
ARG USER_GID

# Then create the user with the right UID
RUN getent group ${USER_GID} || groupadd --gid ${USER_GID} user
RUN useradd --uid ${USER_UID} --gid ${USER_GID} --shell /bin/bash --create-home user

USER user

WORKDIR /home/user
RUN wget -q -O- https://github.com/vim/vim/archive/refs/tags/v9.1.1382.tar.gz | tar -zxvf -
WORKDIR /home/user/vim-9.1.1382
RUN CC=gcc-11 ./configure --enable-python3interp=dynamic --enable-perlinterp=dynamic --prefix=/home/user/local
RUN make -j "$(nproc)"
RUN make install

# The real thing

FROM debian:12-slim

ARG DEV_PKGS

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y locales ca-certificates wget gnupg

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN wget -q -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add -

RUN echo 'deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-19 main' > /etc/apt/sources.list.d/archive_uri-http_apt_llvm_org_bookworm_-bookworm.list

RUN apt-get install -y clang-format-19 clangd-19 \
    && apt-get install -y git exuberant-ctags wget xz-utils libpython3.11 libperl5.36 libncurses6 ca-certificates silversearcher-ag ${DEV_PKGS} \
    && rm -rf /var/lib/apt/lists/*

ARG USER_UID
ARG USER_GID

# Then create the user with the right UID
RUN getent group ${USER_GID} || groupadd --gid ${USER_GID} user
RUN useradd --uid ${USER_UID} --gid ${USER_GID} --shell /bin/bash --create-home user

WORKDIR /usr/local/bin
RUN ln -s /home/user/node-v16.19.0-linux-x64/bin/node node
RUN ln -s /home/user/node-v16.19.0-linux-x64/bin/npm npm
RUN ln -s /home/user/node-v16.19.0-linux-x64/bin/npx npx

USER user

# Copy the vim build from the builder. No need for gcc stuff in the final image.
COPY --from=builder --chown=user:user /home/user/local /home/user/local

WORKDIR /home/user
RUN git clone https://github.com/ttsiodras/dotvim .vim
RUN ln -s .vim/.vimrc
WORKDIR /home/user/.vim
RUN git submodule init
RUN git submodule update --init --recursive --force --remote

WORKDIR /home/user
RUN wget -q -O- https://nodejs.org/dist/v16.19.0/node-v16.19.0-linux-x64.tar.xz | tar -Jxvf -

WORKDIR /home/user
RUN mkdir bin.local
RUN bash -c 'echo "export PATH=/home/user/node-v16.19.0-linux-x64/bin:/home/user/bin.local:$PATH" > bin.local/vim'
RUN bash -c 'echo "/home/user/local/bin/vim \"\$@\"" >>  bin.local/vim'
RUN chmod +x bin.local/vim
RUN ln -s /usr/bin/clangd-19 /home/user/bin.local/clangd
RUN bash -c 'echo "#!/bin/bash" > bin.local/clangd-mine'
RUN bash -c 'echo "exec /usr/bin/clangd-19 -header-insertion=never" > bin.local/clangd-mine'
RUN chmod +x bin.local/clangd-mine

RUN /home/user/local/bin/vim +PlugInstall +qall

RUN /home/user/local/bin/vim +"CocInstall -sync coc-pyright" +qall
