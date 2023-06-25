{ pkgs, ... }: {
  home.packages = [ pkgs.flameshot ];
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "elementary";
      icon-theme = "elementary";
    };
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
    "org/pantheon/desktop/gala/keybindings" = {
      screenshot =
        [ "" ]; # disable default screenshot key and use it for Flameshot
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
      terminal = [ "" ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
      {
        binding = "Print";
        command = "flameshot gui";
        name = "flameshot";
      };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "<Ctrl><Shift><Alt><Super>h" ];
      toggle-tiled-right = [ "<Ctrl><Shift><Alt><Super>l" ];
    };
  };

  gtk = {
    iconTheme = {
      name = "elementary";
      package = pkgs.pantheon.elementary-icon-theme;
    };
  };
}
