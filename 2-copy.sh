#!/bin/bash

set -ex

NIXADDR="127.0.0.1"
NIXPORT=8022
NIXUSER="mshen"

rsync -av -e "ssh -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${NIXPORT}" \
  --exclude='.git/' \
  --rsync-path="sudo rsync" \
  ./ root@"${NIXADDR}":/nix-config
