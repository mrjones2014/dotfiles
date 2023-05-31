{ config, pkgs, lib, ... }:

let
  inherit (pkgs) stdenv;
  inherit (stdenv) isLinux;
  inherit (stdenv) isDarwin;
in {
  home.username = "mat";
  home.homeDirectory = if isLinux then "/home/mat" else "/Users/mat";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "22.11"; # Please read the comment before changing.
  xdg.enable = true;
  home.packages = [
    pkgs.obsidian
    pkgs.mdbook
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
    (pkgs.fetchFromGitHub {
      owner = "nix-community";
      repo = "nurl";
      rev = "ca1e2596fdd64de0314aa7c201e5477f0d8c3ab7";
      hash = "sha256-xN6f9XStY3jqEA/nMb7QOnMDBrkhdFRtke0cCQddBRs=";
    })
  ] ++ lib.lists.optionals isDarwin [
    # put macOS specific packages here
  ] ++ lib.lists.optionals isLinux [
    # put Linux specific packages here
    pkgs.xclip
    pkgs.librewolf
    pkgs.signal-desktop
    pkgs.qbittorrent
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "obsidian" ];

  # link config files, if a dedicated module exists (below)
  # it will handle its own config
  xdg.configFile = {
    "hammerspoon" = {
      source = ../hammerspoon;
      recursive = true;
    };
    "nix/nix.conf".source = ../conf.d/nix.conf;
    "config-paths.yml".source = ../conf.d/config-paths.yml;
    # make .desktop files show up in application launcher on Linux
    "op/plugins.sh".source = ../conf.d/op_cli_plugins.sh;
  };
  home.file."${config.home.homeDirectory}/.xprofile".source =
    ../conf.d/.xprofile;

  home.activation.opDirPermissions = "chmod 700 ${config.xdg.configHome}/op";

  imports = [
    ./modules/nvim.nix
    ./modules/fish.nix
    ./modules/starship.nix
    ./modules/atuin.nix
    ./modules/bat.nix
    ./modules/git.nix
    ./modules/rust.nix
    ./modules/ssh.nix
    ./modules/wezterm.nix
    ./modules/gnome_tweaks.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.direnv.enable = true;
}
