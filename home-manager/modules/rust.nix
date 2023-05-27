{ config, pkgs, lib, ... }: {
  home.sessionVariables = {
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
  };

  home.packages = with pkgs;
    [ cargo-outdated cargo-update cargo-nextest rustup ]
    ++ lib.lists.optionals pkgs.stdenv.isLinux (with pkgs;
      [
        clang # Provides `cc` for any *-sys crates
      ]);

  home.activation.installRustAnalyzer =
    "${pkgs.rustup}/bin/rustup default stable && ${pkgs.rustup}/bin/rustup component add rust-analyzer";
}
