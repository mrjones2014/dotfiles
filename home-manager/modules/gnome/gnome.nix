{ ... }: {
  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "close,minimize,maximize,appmenu:";
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      favorite-apps = [
        "org.gnome.Settings.desktop"
        "org.gnome.Nautilus.desktop"
        "org.wezfurlong.wezterm.desktop"
        "1password.desktop"
        "signal-desktop.desktop"
        "librewolf.desktop"
        "discord.desktop"
        "steam.desktop"
      ];
      enabled-extensions = [
        "trayIconsReloaded@selfmade.pl"
        "search-light@icedman.github.com"
        "dash-to-dock@micxgx.gmail.com"
        "no-overview@fthx"
        "gTile@vibou"
      ];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      clock-show-weekday = true;
    };
    "org/gnome/shell/extensions/search-light" = {
      shortcut-search = [ "<Super>space" ];
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
      intellihide-mode = "ALL_WINDOWS";
    };
  };
}
