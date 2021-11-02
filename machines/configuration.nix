{ config, pkgs, currentSystem, ... }:

{
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    hostName = "dev";
    useDHCP = false;
    interfaces.enp0s3.useDHCP = true;
  };

  virtualisation.docker.enable = true;

  # We expect to run the VM on hidpi machines.
  hardware.video.hidpi.enable = true;

  time.timeZone = "America/Detroit";
  i18n.defaultLocale = "en_US.UTF-8";
  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    gnumake
    killall
    niv
  ];
  
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = true;
  services.openssh.permitRootLogin = "yes";

  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
