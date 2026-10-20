{ isHomeManager }:
{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  caches = [
    {
      url = "https://mrjones2014-dotfiles.cachix.org";
      public-key = "mrjones2014-dotfiles.cachix.org-1:c66wfzthG6KZEWnltlzW/EjhlH9FwUVi5jM4rVD1Rw4=";
    }
    {
      url = "https://jj-gh.cachix.org";
      public-key = "jj-gh.cachix.org-1:N1uFBMDd9znlhDa68BRqLSXYzXXJ2+WHVuwxpGxCtDo=";
    }
    {
      url = "https://nix-community.cachix.org";
      public-key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    }
    {
      url = "https://catppuccin.cachix.org";
      public-key = "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU=";
    }
  ];
  cache-urls = lib.map (c: c.url) caches;
  cache-pubkeys = lib.map (c: c.public-key) caches;
in
{
  nix = {
    package = lib.mkDefault pkgs.lixPackageSets.latest.lix;
    settings =
      { }
      // lib.optionalAttrs (!isHomeManager) {
        experimental-features = [ "nix-command flakes" ];
        keep-derivations = true;
        keep-outputs = true;
        extra-substituters = cache-urls;
        extra-trusted-substituters = cache-urls;
        extra-trusted-public-keys = cache-pubkeys;
      };
    # enable `nix-shell -p nixpkgs#something` without using channels
    # also use the exact version of nixpkgs from the flake the system is built from
    # to avoid cache misses
    nixPath = lib.mkForce [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
