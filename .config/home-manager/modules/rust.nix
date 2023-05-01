{ config, pkgs, lib, ... }:
{
  home.sessionVariables = {
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
  };

  home.packages = with pkgs; [
    cargo-outdated
    cargo-update
    cargo-nextest
    rustup
  ] ++ lib.lists.optionals pkgs.stdenv.isLinux (with pkgs; [
    # binutils now conflicts with clang as well, turning this off for now...
    # binutils # For some reason conflicts on darwin
    clang # Provides `cc` for any *-sys crates
  ]);
}
