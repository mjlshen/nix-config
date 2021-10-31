#!/bin/bash

set -ex

NIXNAME="NixOS"
NIXPORT=8022

VBoxManage createvm --name "${NIXNAME}" --ostype Linux_64 --register
VBoxManage modifyvm "${NIXNAME}" --cpus 4 --memory 8192
VBoxManage modifyvm "${NIXNAME}" --vram 128 --accelerate3d on --graphicscontroller vmsvga
VBoxManage modifyvm "${NIXNAME}" --firmware efi
VBoxManage modifyvm "${NIXNAME}" --audio none
VBoxManage modifyvm "${NIXNAME}" --natpf1 "SSH,tcp,,${NIXPORT},,22"
VBoxManage storagectl "${NIXNAME}" --name IDE --add ide --controller PIIX4 --portcount 2 --hostiocache on --bootable on
VBoxManage createmedium disk --filename "/Users/mshen/VirtualBox VMs/${NIXNAME}/${NIXNAME}.vdi" --size 51200 --format VDI --variant Fixed
VBoxManage storageattach "${NIXNAME}" --storagectl IDE --port 0 --device 0 --type hdd --medium "/Users/mshen/VirtualBox VMs/${NIXNAME}/${NIXNAME}.vdi"
VBoxManage storageattach "${NIXNAME}" --storagectl IDE --port 1 --device 0 --type dvddrive --medium "/Users/mshen/Downloads/nixos-minimal-21.05.3957.66d6ec6ed2d-x86_64-linux.iso"

VBoxManage startvm "${NIXNAME}" --type gui
