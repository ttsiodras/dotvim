#!/usr/bin/env bash
# run Vim in Docker with no external network visible. 
# Translation: lessen the trust in the language servers.

HOST_PWD="$(pwd -P)"

docker run --rm -it \
  --network none \
  -v "${HOST_PWD}:${HOST_PWD}" \
  -w "${HOST_PWD}" \
  -u "$(id -u):$(id -g)" \
  vim-ttsiodras:latest \
  /bin/bash -c "/home/user/bin.local/vim \"$@\""
