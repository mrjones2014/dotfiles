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
  neovim-nightly = pkgs.callPackage ./neovim-nightly.nix { inherit neovim; };
  cbfmt = pkgs.callPackage ./cbfmt.nix { };
}
