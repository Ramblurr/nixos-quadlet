{
  description = "NixOS module for Podman Quadlet";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      systemdLib = import "${nixpkgs}/nixos/lib/systemd-lib.nix";
    in
    {
      nixosModules.quadlet = import ./nixos-module.nix { inherit systemdLib; };
      homeManagerModules.quadlet = import ./home-manager-module.nix { inherit systemdLib; };
      homeManagerModules.default = self.homeManagerModules.quadlet;
    };
}
