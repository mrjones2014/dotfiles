{ inputs, pkgs, ... }:
let
  inherit (pkgs) stdenv;
  inherit (stdenv) isLinux;
  inherit (inputs.neovim-flake) packages;
  neovim = if isLinux then
    packages.x86_64-linux.neovim
  else
    packages.aarch64-darwin.neovim;
in {
  # neovim-nightly on macOS currently requires a custom patch to build successfully
  # see: https://github.com/nix-community/neovim-nightly-overlay/issues/176
  # see: https://github.com/hurricanehrndz/nixcfg/commit/69e37b6ef878ddba8a8af1bd514f967879ea0082
  neovim-nightly = if isLinux then
    neovim
  else
    pkgs.callPackage ./neovim-nightly.nix { inherit neovim; };
}
