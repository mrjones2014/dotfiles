{ config, pkgs, lib, ... }:
let
  inherit (pkgs) stdenv;
  inherit (stdenv) isLinux;
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    (pkgs.nerdfonts.override { fonts = ["FiraCode"]; })
    pkgs.catimg
    pkgs.gh
    pkgs.thefuck
    pkgs.wget
    pkgs.fzf
    pkgs.ripgrep
    pkgs.fnm
    pkgs.jq
    pkgs.glow
    pkgs.exa
    pkgs.neovim
    pkgs.tealdeer
    pkgs.go
    pkgs.nixfmt
    (pkgs.fetchFromGitHub {
      owner = "nix-community";
      repo = "nurl";
      rev = "ca1e2596fdd64de0314aa7c201e5477f0d8c3ab7";
      hash = "sha256-xN6f9XStY3jqEA/nMb7QOnMDBrkhdFRtke0cCQddBRs=";
    })
    #pkgs.hammerspoon, no package
  ];

  imports = [
    ./modules/fish.nix
    ./modules/starship.nix
    ./modules/topgrade.nix
    ./modules/atuin.nix
    ./modules/bat.nix
    ./modules/git.nix
    ./modules/rust.nix
    ./modules/ssh.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
