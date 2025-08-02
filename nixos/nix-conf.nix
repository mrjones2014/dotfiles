{ isHomeManager }:
{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cachix = {
    url = "https://mrjones2014-dotfiles.cachix.org";
    public-key = "mrjones2014-dotfiles.cachix.org-1:c66wfzthG6KZEWnltlzW/EjhlH9FwUVi5jM4rVD1Rw4=";
  };
in
{
  nix = {
    package = lib.mkDefault pkgs.lixPackageSets.latest.lix;
    settings = {
      extra-substituters = [ cachix.url ];
      extra-trusted-public-keys = [ cachix.public-key ];
      keep-outputs = true;
      keep-derivations = true;
      experimental-features = "nix-command flakes";
    }
    // lib.optionalAttrs (!isHomeManager) {
      trusted-substituters = [ cachix.url ];
      trusted-public-keys = [ cachix.public-key ];
    };
    # enable `nix-shell -p nixpkgs#something` without using channels
    # also use the exact version of nixpkgs from the flake the system is built from
    # to avoid cache misses
    nixPath = lib.mkForce [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
