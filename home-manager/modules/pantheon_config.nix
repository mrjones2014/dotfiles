{ pkgs, config, ... }:
let
  autostartPrograms =
    if pkgs.stdenv.isDarwin then [ ] else [ pkgs._1password-gui ];
  wallpaperImg = pkgs.fetchurl {
    url =
      "https://user-images.githubusercontent.com/8648891/246180692-b8144052-e947-47b0-b59c-ea1022b9b629.jpg";
    hash = "sha256-itnhNPYvQLfCULNrEZqP+3VBQVmEmvh9wv6C2F3YKQU=";
  };
in {
  # autostart 1Password; workaround for https://github.com/nix-community/home-manager/issues/3447
  home.file = builtins.listToAttrs (map (pkg: {
    name = ".config/autostart/" + pkg.pname + ".desktop";
    value = if pkg ? desktopItem then {
      # Application has a desktopItem entry.
      # Assume that it was made with makeDesktopEntry, which exposes a
      # text attribute with the contents of the .desktop file
      text = pkg.desktopItem.text;
    } else {
      # Application does *not* have a desktopItem entry. Try to find a
      # matching .desktop name in /share/apaplications
      source = (pkg + "/share/applications/" + pkg.pname + ".desktop");
    };
  }) autostartPrograms);

  # see  https://github.com/wimpysworld/nix-config/blob/b8a260ddea1bbf088461f7272382d99acbf86ce7/home-manager/_mixins/desktop/pantheon.nix
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = "elementary";
      icon-theme = "elementary";
      enable-hot-corners = false;
      clock-show-weekday = true;
    };
    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaperImg}";
    };
    "org/gnome/desktop/datetime" = { automatic-timezone = true; };
    "io/elementary/files/preferences" = { singleclick-select = true; };
    "io/elementary/settings-daemon/housekeeping" = {
      cleanup-downloads-folder = true;
    };
    "org/pantheon/desktop/gala/appearance" = {
      button-layout = "close,minimize,maximize,appmenu:";
    };
    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "<Ctrl><Shift><Alt><Super>h" ];
      toggle-tiled-right = [ "<Ctrl><Shift><Alt><Super>l" ];
    };
    "org/pantheon/desktop/gala/mask-corners" = { enable = false; };
  };
  gtk = {
    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      extraConfig = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk3 = { extraConfig = { gtk-application-prefer-dark-theme = 1; }; };

    gtk4 = { extraConfig = { gtk-application-prefer-dark-theme = 1; }; };

    iconTheme = {
      name = "elementary";
      package = pkgs.pantheon.elementary-icon-theme;
    };
  };
}
