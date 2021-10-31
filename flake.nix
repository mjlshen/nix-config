{
  description = "NixOS config for mshen";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";

      # Tell home-manager to use the above version of nixpkgs and not its own
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
  let
    mkVM = import ./lib/mkvm.nix;
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };

    lib = nixpkgs.lib;

  in {
    nixosConfigurations.dev = mkVM "dev" {
      inherit nixpkgs home-manager system;
      user = "mshen";
    };
  };
}
