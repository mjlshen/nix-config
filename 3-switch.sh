#!/bin/bash

set -ex

NIXADDR="127.0.0.1"
NIXPORT=8022

ssh -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@"${NIXADDR}" -p "${NIXPORT}" "
  nixos-rebuild switch --flake \"/nix-config#dev\"
"
