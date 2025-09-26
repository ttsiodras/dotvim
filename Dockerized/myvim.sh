#!/usr/bin/env bash
# run Vim in Docker with no external network visible. 
# Translation: lessen the trust in the language servers.

HOST_PWD="$(pwd -P)"

# If your YAML files are using external schemas, you may 
# need to enable the network:
#
# docker run --rm -it \
#  --add-host gitlab.someurl:172.17.0.1 \
#  -v "${HOST_PWD}:${HOST_PWD}" \
#  ...

docker run --rm -it \
  --network none \
  -v "${HOST_PWD}:${HOST_PWD}" \
  -w "${HOST_PWD}" \
  -u "$(id -u):$(id -g)" \
  vim-ttsiodras:latest \
  /bin/bash -c "/home/user/bin.local/vim \"$@\""
