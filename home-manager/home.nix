{ inputs, config, pkgs, lib, isDarwin, isLinux, isThinkpad, ... }: {
  nixpkgs.overlays = [
    (final: prev:
      (import ../packages {
        inherit inputs;
        inherit pkgs;
        inherit (prev) system;
      }))
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
      [ spotify gnumake ] ++ lib.lists.optionals isDarwin [
        # put macOS specific packages here
        darwin-rebuild
        taskwarrior3
      ] ++ lib.lists.optionals isLinux [
        # put Linux specific packages here
        # vesktop discord client, I don't like
        # vesktop's icon, so override it
        (vesktop.overrideAttrs (oldAttrs: {
          desktopItems = [
            (makeDesktopItem {
              name = "vesktop";
              desktopName = "Discord";
              exec = "vesktop %U";
              icon = "discord";
              startupWMClass = "Vesktop";
              genericName = "Internet Messenger";
              keywords = [ "discord" "vencord" "electron" "chat" ];
              categories = [ "Network" "InstantMessaging" "Chat" ];
            })
          ];
        }))
        signal-desktop
        qbittorrent
        vlc
        # cura
        r2modman
        parsec-bin
        ungoogled-chromium
        standardnotes
        zen-browser
      ] ++ lib.lists.optionals isThinkpad [ ]
      ++ lib.lists.optionals (isLinux && (!isThinkpad)) [ obs-studio ];
    file."${config.home.homeDirectory}/.xprofile".text = ''
      export XDG_DATA_DIRS="$XDG_DATA_DIRS:/home/mat/.nix-profile/share"
    '';
  };
  xdg = {
    enable = true;
    # for discord app icon
    dataFile."icons/discord.png".source = ./discord.png;
    # link config files, if a dedicated module exists (below)
    # it will handle its own config
    configFile = {
      "hammerspoon" = {
        source = ../hammerspoon;
        recursive = true;
      };
    };
  };

  imports = [
    ./shared.nix
    ./modules/terminal.nix
    ./modules/_1password-shell.nix
    ./modules/espanso.nix
    ./modules/gnome
    ./modules/recyclarr.nix
    ./modules/jujutsu.nix
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
