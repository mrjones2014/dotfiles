{
  pkgs,
  lib,
  inputs,
  isDarwin,
  ...
}:
{
  nix = {
    package = lib.mkDefault pkgs.lixPackageSets.latest.lix;
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [
        "root"
        (if isDarwin then "mat.jones" else "mat") # username is set by MDM on work mac :/
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
