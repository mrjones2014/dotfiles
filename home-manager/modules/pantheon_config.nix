{ pkgs, config, ... }:
let
  wallpaperImg = pkgs.fetchurl {
    url =
      "https://user-images.githubusercontent.com/8648891/246180692-b8144052-e947-47b0-b59c-ea1022b9b629.jpg";
    hash = "sha256-itnhNPYvQLfCULNrEZqP+3VBQVmEmvh9wv6C2F3YKQU=";
  };
in {
  # workaround for https://github.com/nix-community/home-manager/issues/3447
  # autostart 1Password in the background so I can use the SSH agent without manually opening the app first
  xdg.configFile."autostart/1password.desktop".text = ''
     [Desktop Entry]
    Name=1Password
    Exec=1password --silent
    Terminal=false
    Type=Application
    Icon=1password
    StartupWMClass=1Password
    Comment=Password manager and secure wallet
    MimeType=x-scheme-handler/onepassword;
    Categories=Office;
  '';

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
    "org/pantheon/desktop/gala/mask-corners" = { enable = false; };
    # key bindings
    "org/pantheon/desktop/gala/behavior" = {
      overlay-action =
        "io.elementary.wingpanel --toggle-indicator=app-launcher";
    };
    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "<Ctrl><Shift><Alt><Super>h" ];
      toggle-tiled-right = [ "<Ctrl><Shift><Alt><Super>l" ];
    };
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
