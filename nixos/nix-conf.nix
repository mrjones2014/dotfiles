{ isHomeManager }:
{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cachix-personal = {
    url = "https://mrjones2014-dotfiles.cachix.org";
    public-key = "mrjones2014-dotfiles.cachix.org-1:c66wfzthG6KZEWnltlzW/EjhlH9FwUVi5jM4rVD1Rw4=";
  };
  cachix-nix-community = {
    url = "https://nix-community.cachix.org";
    public-key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  };
in
{
  nix = {
    package = lib.mkDefault pkgs.lixPackageSets.latest.lix;
    settings =
      { }
      // lib.optionalAttrs (!isHomeManager) {
        experimental-features = "nix-command flakes";
        keep-derivations = true;
        keep-outputs = true;
        substituters = [
          "https://cache.nixos.org"
          cachix-personal.url
          cachix-nix-community.url
        ];
        trusted-substituters = [
          cachix-personal.url
          cachix-nix-community.url
        ];
        trusted-public-keys = [
          cachix-personal.public-key
          cachix-nix-community.public-key
        ];
      };
    # enable `nix-shell -p nixpkgs#something` without using channels
    # also use the exact version of nixpkgs from the flake the system is built from
    # to avoid cache misses
    nixPath = lib.mkForce [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
