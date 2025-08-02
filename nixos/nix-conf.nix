{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  nix = {
    package = lib.mkDefault pkgs.lixPackageSets.latest.lix;
    settings = {
      trusted-substituters = [ "https://mrjones2014-dotfiles.cachix.org" ];
      trusted-public-keys = [
        "mrjones2014-dotfiles.cachix.org-1:c66wfzthG6KZEWnltlzW/EjhlH9FwUVi5jM4rVD1Rw4="
      ];
      keep-outputs = true;
      keep-derivations = true;
      experimental-features = "nix-command flakes";
    };
    # enable `nix-shell -p nixpkgs#something` without using channels
    # also use the exact version of nixpkgs from the flake the system is built from
    # to avoid cache misses
    nixPath = lib.mkForce [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
