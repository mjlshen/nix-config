#!/bin/bash

set -ex

NIXADDR="127.0.0.1"
NIXPORT=8022
NIXBLOCKDEVICE=sda

ssh -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@"${NIXADDR}" -p "${NIXPORT}" "
  parted /dev/${NIXBLOCKDEVICE} -- mklabel gpt
  parted /dev/${NIXBLOCKDEVICE} -- mkpart primary 512MiB -8GiB
  parted /dev/${NIXBLOCKDEVICE} -- mkpart primary linux-swap -8GiB 100%
  parted /dev/${NIXBLOCKDEVICE} -- mkpart ESP fat32 1MiB 512MiB
  parted /dev/${NIXBLOCKDEVICE} -- set 3 esp on
  mkfs.ext4 -L nixos /dev/${NIXBLOCKDEVICE}1
  mkswap -L swap /dev/${NIXBLOCKDEVICE}2
  mkfs.fat -F 32 -n boot /dev/${NIXBLOCKDEVICE}3
  mount /dev/disk/by-label/nixos /mnt
  mkdir -p /mnt/boot
  mount /dev/disk/by-label/boot /mnt/boot
  nixos-generate-config --root /mnt
  sed --in-place '/system\.stateVersion = .*/a \
    \  nix.package = pkgs.nixUnstable;\n\
  nix.extraOptions = \"experimental-features = nix-command flakes\";\n\
  services.openssh.enable = true;\n\
  services.openssh.passwordAuthentication = true;\n\
  services.openssh.permitRootLogin = \"yes\";\n\
  users.users.root.initialPassword = \"root\";' /mnt/etc/nixos/configuration.nix
  nixos-install --no-root-passwd
  reboot
"
