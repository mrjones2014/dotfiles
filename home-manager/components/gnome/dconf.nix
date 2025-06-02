{
  pkgs,
  lib,
  isThinkpad,
  ...
}:
let
  wallpaperImg = pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/z8/wallhaven-z8g6wv.jpg";
    hash = "sha256-AJLXmM86rnuoT0I93ewFocxFKwikIOt1h+JDOmWzQzg=";
  };
  gnomeExtensions = with pkgs.gnomeExtensions; [
    dash-to-dock
    tray-icons-reloaded
    gtile
    search-light
    user-themes
    quick-settings-tweaker
  ];
  enabled-extensions = map (ext: ext.extensionUuid) gnomeExtensions;
in
{
  home.packages = gnomeExtensions;
  # see https://github.com/wimpysworld/nix-config/blob/b8a260ddea1bbf088461f7272382d99acbf86ce7/home-manager/_mixins/desktop/pantheon.nix
  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      # If this doesn't seem to be working, check `gsettings get org.gnome.settings-daemon.plugins.xsettings overrides`
      # window button order may be in there
      button-layout = "close,minimize,maximize,appmenu:";
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      disable-extension-version-validation = true;
      favorite-apps = [
        "org.gnome.Settings.desktop"
        "org.gnome.Nautilus.desktop"
        "spotify.desktop"
        "zen-beta.desktop"
        "com.mitchellh.ghostty.desktop"
        "standard-notes.desktop"
        "1password.desktop"
        "signal.desktop"
        "vesktop.desktop"
      ] ++ lib.lists.optionals (!isThinkpad) [ "steam.desktop" ];
      inherit enabled-extensions;
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      clock-show-weekday = true;
    };
    "org/gnome/shell/extensions/gtile" = {
      auto-close-keyboard-shortcut = [ true ];
      grid-sizes = "11x1";
      # right 2/3rds of screen
      resize1 = "11x1 5:1 11:1";
      preset-resize-1 = [ "<Shift><Control><Alt><Super>l" ];
      # left 1/3rd of screen
      resize2 = "11x1 1:1 4:1";
      preset-resize-2 = [ "<Shift><Control><Alt><Super>h" ];
      # center 2/3rds of screen
      resize3 = "5x1 2:1 4:1";
      preset-resize-3 = [ "<Shift><Control><Alt><Super>k" ];
    };
    "org/gnome/shell/extensions/dash-to-dock" = {
      dash-max-icon-size = 48;
      intellihide-mode = "ALL_WINDOWS";
      disable-overview-on-startup = true;
      show-show-apps-button = false;
      running-indicator-style = "DOTS";
      apply-custom-theme = false;
    };
    "org/gnome/shell/extensions/trayIconsReloaded".icons-limit = 10;
    "org/gnome/shell/extensions/quick-settings-tweaks" = {
      output-show-selected = true;
      input-show-selected = true;
      input-always-show = true;
      volume-mixer-enabled = true;
    };
    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaperImg}";
      picture-uri-dark = "file://${wallpaperImg}";
    };
    "org/gnome/desktop/datetime".automatic-timezone = true;
    "org/gnome/desktop/wm/keybindings" = {
      move-to-monitor-left = [ "<Shift><Control><Alt>h" ];
      move-to-monitor-right = [ "<Shift><Control><Alt>l" ];
      move-to-monitor-up = [ "<Shift><Control><Alt>k" ];
      move-to-monitor-down = [ "<Shift><Control><Alt>j" ];
    };
    "org/gnome/desktop/peripherals/touchpad".send-events = "enabled";
    "org/gnome/shell/extensions/search-light" = {
      shortcut-search = [ "<Super>space" ];
    };
    "org/gnome/mutter/keybindings" = {
      switch-monitor = [ ]; # disable stupid ass default <Super>+p defautl shortcut
    };
  };
}
