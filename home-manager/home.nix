{ inputs, config, pkgs, lib, isDarwin, isLinux, ... }:

{
  nixpkgs.overlays = [
    (final: prev:
      (import ../packages {
        inherit inputs;
        inherit pkgs;
      }))
    inputs.neovim-nightly-overlay.overlay
  ];
  home = {
    username = "mat";
    homeDirectory = if isLinux then "/home/mat" else "/Users/mat";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "22.11";
    packages = with pkgs;
      [ obsidian mdbook spotify ] ++ lib.lists.optionals isDarwin [
        # put macOS specific packages here
        # xcodes
      ] ++ lib.lists.optionals isLinux [
        # put Linux specific packages here
        (discord.override {
          withOpenASAR = true;
          withVencord = true;
        })
        signal-desktop
        qbittorrent
        vlc
        cura
        r2modman
      ];
    file."${config.home.homeDirectory}/.xprofile".text = ''
      export XDG_DATA_DIRS="$XDG_DATA_DIRS:/home/mat/.nix-profile/share"
    '';
  };

  xdg.enable = true;
  # link config files, if a dedicated module exists (below)
  # it will handle its own config
  xdg.configFile = {
    "hammerspoon" = {
      source = ../hammerspoon;
      recursive = true;
    };
    "nix/nix.conf".text = ''
      experimental-features = nix-command flakes
      # see https://github.com/nix-community/nix-direnv#via-home-manager
      keep-derivations = true
      keep-outputs = true
    '';
  };

  imports = [
    # TODO figure out how to load the arkenfox flake module conditionally, since nixpkgs Firefox is broken on macOS
    # ./modules/arkenfox.nix
    ./shared.nix
    ./modules/_1password-shell.nix
    ./modules/rofi.nix
    ./modules/espanso.nix
    ./modules/wezterm.nix
    ./modules/librewolf.nix
    ./modules/gnome
    ./modules/recyclarr.nix
    ../nixos-modules/allowed-unfree.nix
  ];

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    # Direnv integration for flakes
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
  };
}
