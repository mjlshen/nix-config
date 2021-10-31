#!/bin/bash

set -ex

NIXADDR="127.0.0.1"
NIXPORT=8022
NIXUSER="mshen"

rsync -av -e "ssh -p ${NIXPORT}" \
  --exclude='.#*' \
  --exclude='S.*' \
  --exclude='*.conf' \
  ~/.gnupg/ "${NIXUSER}@${NIXADDR}":~/.gnupg

rsync -av -e "ssh -p ${NIXPORT}" \
  --exclude='environment' \
  ~/.ssh/ "${NIXUSER}@${NIXADDR}":~/.ssh