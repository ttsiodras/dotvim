FROM debian:12

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
    && apt-get install -y git exuberant-ctags wget xz-utils libpython3-dev libperl-dev gcc-11 g++-11 make libncurses-dev ca-certificates silversearcher-ag ${DEV_PKGS} \
    && rm -rf /var/lib/apt/lists/*

ARG USER_UID
ARG USER_GID

RUN groupadd --gid ${USER_GID} dev \
 && useradd --uid ${USER_UID} --gid dev --shell /bin/bash --create-home dev

WORKDIR /usr/local/bin
RUN ln -s /home/dev/node-v16.19.0-linux-x64/bin/node node
RUN ln -s /home/dev/node-v16.19.0-linux-x64/bin/npm npm
RUN ln -s /home/dev/node-v16.19.0-linux-x64/bin/npx npx

USER dev
WORKDIR /home/dev

RUN git clone --recurse-submodules https://github.com/ttsiodras/dotvim .vim
RUN ln -s .vim/.vimrc

RUN wget -q -O- https://nodejs.org/dist/v16.19.0/node-v16.19.0-linux-x64.tar.xz | tar -Jxvf -
RUN wget -q -O- https://github.com/vim/vim/archive/refs/tags/v9.1.1382.tar.gz | tar -zxvf -
WORKDIR /home/dev/vim-9.1.1382
RUN CC=gcc-11 ./configure --enable-python3interp=dynamic --enable-perlinterp=dynamic --prefix=/home/dev/local
RUN make -j
RUN make install

WORKDIR /home/dev

RUN mkdir bin.local
RUN bash -c 'echo "export PATH=/home/dev/node-v16.19.0-linux-x64/bin:/home/dev/bin.local:$PATH" > bin.local/vim'
RUN bash -c 'echo "/home/dev/local/bin/vim \"\$@\"" >>  bin.local/vim'
RUN chmod +x bin.local/vim
RUN ln -s /usr/bin/clangd-19 /home/dev/bin.local/clangd

RUN bash -c 'echo "#!/bin/bash" > bin.local/clangd-mine'
RUN bash -c 'echo "exec /usr/bin/clangd-19 -header-insertion=never" > bin.local/clangd-mine'
RUN chmod +x bin.local/clangd-mine

RUN /home/dev/local/bin/vim +PlugInstall +qall

RUN /home/dev/local/bin/vim +"CocInstall -sync coc-pyright" +qall
