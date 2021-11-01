# NixOS Dev Environment

This repo will create a NixOS VM and configure it to my liking for use as a repeatable and declarative dev environment.

Inspired by [https://github.com/mitchellh/nixos-config](https://github.com/mitchellh/nixos-config)

## Steps

1. Install VirtualBox and the Extension Pack

```bash
brew install virtualbox virtualbox-extension-pack
```

2. Download or build a NixOS ISO

3. Create the VirtualBox VM

```bash
make create-vm
```

This will port-forward 22 on the VM to 8022 locally and configure the VM with 4 CPUs, 8GB RAM, and a 50GB HDD. Afterwards, the VM will launch using the Live CD - simply change the root password to something easy to remember, like root (it's a temporary password) and continue.

```bash
sudo passwd root
```

4. Install NixOS

```bash
make install-nixos
```

This will SSH to the VM as root using the password set earlier and install NixOS, enabling flakes, setting the root password to root, and enabling SSH.

5. Configure NixOS

```bash
make config-nixos
```

This will SSH to the VM as root to rsync over the contents of this repo, then run `nixos-rebuild switch --flake`, which builds the new configuration, switches to it, and makes it the boot default option in GRUB. Then, it will copy over GPG and SSH keys from the local machine and reboot. Afterwards the dev environment is completely configured!
