{
  pkgs,
  lib,
  inputs,
  isLinux,
  ...
}:
{
  nix = {
    package = lib.mkDefault pkgs.lix;
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-users = [
        "root"
        "mat"
      ];
      keep-outputs = true;
      keep-derivations = true;
      auto-optimise-store = if isLinux then true else false; # https://github.com/NixOS/nix/issues/7273

      experimental-features = "nix-command flakes";
    };
    # enable `nix-shell -p nixpkgs#something` without using channels
    # also use the exact version of nixpkgs from the flake the system is built from
    # to avoid cache misses
    nixPath = lib.mkForce [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
