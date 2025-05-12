#!/usr/bin/env bash
# ~/.bin.local/vim — run Vim in Docker with no external network

HOST_PWD="$(pwd -P)"

docker run --rm -it \
  --network none \
  -v "${HOST_PWD}:${HOST_PWD}" \
  -w "${HOST_PWD}" \
  -u "$(id -u):$(id -g)" \
  vim-ttsiodras:latest \
  /bin/bash -c "/home/dev/bin.local/vim \"$@\""

#  -v "${HOME}/.vimrc:/home/dev/.vimrc:ro" \
#  -v "${HOME}/.vim:/home/dev/.vim:ro" \
