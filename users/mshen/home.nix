{ pkgs, ... }:

{
  users.users.mshen = {
    isNormalUser = true;
    home = "/home/mshen";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$9A.1.dhVK$rg23gTj.7wM8rmydZgfTpgRHKApL1RllplbNhuTyn3QDivyx2Wj0bIPekwB5QrjwXIWOXmdh5AIddhE4EtPoY1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP0xmWv8GfxHMRqbVPeF18kj5lqpw6an/SOveeCgGgno mshen"
    ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix;
}
