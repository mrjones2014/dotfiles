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
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
      "/org/gnome/shell/extensions/search-light" = {
        shortcut-search = [ "<Super>space" ];
      };
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      clock-show-weekday = true;
    };
  };
}
