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
  home.packages = with pkgs;
    [
      obsidian
      mdbook
      cachix
      tokei
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      (fetchFromGitHub {
        owner = "nix-community";
        repo = "nurl";
        rev = "ca1e2596fdd64de0314aa7c201e5477f0d8c3ab7";
        hash = "sha256-xN6f9XStY3jqEA/nMb7QOnMDBrkhdFRtke0cCQddBRs=";
      })
      spotify
      (discord.override { withOpenASAR = true; })
    ] ++ lib.lists.optionals isDarwin [
      # put macOS specific packages here
    ] ++ lib.lists.optionals isLinux [
      # put Linux specific packages here
      xclip
      librewolf
      signal-desktop
      qbittorrent
    ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "obsidian"
      "spotify"
      "discord"
      # This is required for pkgs.nodePackages_latest.vscode-langservers-extracted on NixOS
      # however VS Code should NOT be installed on this system!
      # Use VS Codium instead: https://github.com/VSCodium/vscodium
      "vscode"
    ];

  # link config files, if a dedicated module exists (below)
  # it will handle its own config
  xdg.configFile = {
    "hammerspoon" = {
      source = ../hammerspoon;
      recursive = true;
    };
    "nix/nix.conf".text = ''
      experimental-features = nix-command flakes
      # see https://github.com/nix-community/nix-direnv
      keep-derivations = true
      keep-outputs = true
    '';
    "config-paths.yml".source = ../conf.d/config-paths.yml;
    "op/plugins.sh".source = pkgs.writeScript "op_plugins.sh" ''
      export OP_PLUGIN_ALIASES_SOURCED=1
      alias gh="op plugin run -- gh"
    '';
  };
  home.file."${config.home.homeDirectory}/.xprofile".text = ''
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:/home/mat/.nix-profile/share"
  '';

  home.activation.opDirPermissions = "chmod 700 ${config.xdg.configHome}/op";

  imports = [
    ./modules/nvim.nix
    ./modules/fish.nix
    ./modules/starship.nix
    ./modules/atuin.nix
    ./modules/bat.nix
    ./modules/git.nix
    ./modules/ssh.nix
    ./modules/wezterm.nix
    ./modules/gnome/default.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # Direnv integration for flakes
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
