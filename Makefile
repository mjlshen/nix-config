NIXADDR := 127.0.0.1
NIXPORT := 8022
NIXUSER := mshen
NIXHOSTNAME := dev
NIXVMNAME := NixOS
NIXBLOCKDEVICE := sda

# Path to the NixOS iso
NIXISO ?= "$(HOME)/Downloads/nixos-minimal-21.05.3957.66d6ec6ed2d-x86_64-linux.iso"

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

create-vm:
	VBoxManage createvm \
		--name $(NIXVMNAME) \
		--ostype Linux_64 \
		--register
	VBoxManage modifyvm $(NIXVMNAME) \
		--cpus 4 \
		--memory 8192 \
		--vram 128 \
		--accelerate3d on \
		--graphicscontroller vmsvga \
		--firmware efi \
		--audio none \
		--natpf1 "SSH,tcp,,$(NIXPORT),,22"
	VBoxManage storagectl $(NIXVMNAME) \
		--name IDE \
		--add ide \
		--controller PIIX4 \
		--portcount 2 \
		--hostiocache on \
		--bootable on
	VBoxManage createmedium disk \
		--filename "$(HOME)/VirtualBox VMs/$(NIXVMNAME)/$(NIXVMNAME).vdi" \
		--format VDI \
		--size 51200 \
		--variant Fixed
	VBoxManage storageattach $(NIXVMNAME) \
		--storagectl IDE \
		--port 0 \
		--device 0 \
		--type hdd \
		--medium "$(HOME)/VirtualBox VMs/$(NIXVMNAME)/$(NIXVMNAME).vdi"
	VBoxManage storageattach $(NIXVMNAME) \
		--storagectl IDE \
		--port 1 \
		--device 0 \
		--type dvddrive \
		--medium "$(NIXISO)"
	VBoxManage startvm $(NIXVMNAME) \
		--type gui

install-nixos:
	ssh -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@"$(NIXADDR)" -p "$(NIXPORT)" " \
		parted /dev/$(NIXBLOCKDEVICE) -- mklabel gpt; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart primary 512MiB -8GiB; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart primary linux-swap -8GiB 100%; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart ESP fat32 1MiB 512MiB; \
		parted /dev/$(NIXBLOCKDEVICE) -- set 3 esp on; \
		mkfs.ext4 -L nixos /dev/$(NIXBLOCKDEVICE)1; \
		mkswap -L swap /dev/$(NIXBLOCKDEVICE)2; \
		mkfs.fat -F 32 -n boot /dev/$(NIXBLOCKDEVICE)3; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
			nix.package = pkgs.nixUnstable;\n \
			nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
			services.openssh.enable = true;\n \
			services.openssh.passwordAuthentication = true;\n \
			services.openssh.permitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\"; \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd; \
		reboot; \
	"

config-nixos:
	rsync -av -e 'ssh -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $(NIXPORT)' \
		--exclude='.git/' \
		--rsync-path="sudo rsync" \
		$(MAKEFILE_DIR)/ root@$(NIXADDR):/nix-config
	
	ssh -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $(NIXPORT) root@$(NIXADDR) " \
		sudo nixos-rebuild switch --flake \"/nix-config#${NIXHOSTNAME}\" \
	"

	# GPG keyring
	rsync -av -e 'ssh -p $(NIXPORT)' \
		--exclude='.#*' \
		--exclude='S.*' \
		--exclude='*.conf' \
		$(HOME)/.gnupg/ $(NIXUSER)@$(NIXADDR):~/.gnupg

	# SSH keys
	rsync -av -e 'ssh -p $(NIXPORT)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh

	# Default to headless
	VBoxManage modifyvm $(NIXVMNAME) \
		--defaultfrontend headless

	ssh -p $(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo reboot; \
	"

switch:
	sudo nixos-rebuild switch --flake ".#${NIXHOSTNAME}"

test:
	sudo nixos-rebuild test --flake ".#${NIXHOSTNAME}"
