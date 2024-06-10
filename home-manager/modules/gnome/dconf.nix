{ pkgs, ... }:
let
  wallpaperImg = pkgs.fetchurl {
    url =
      "https://user-images.githubusercontent.com/8648891/246180692-b8144052-e947-47b0-b59c-ea1022b9b629.jpg";
    hash = "sha256-itnhNPYvQLfCULNrEZqP+3VBQVmEmvh9wv6C2F3YKQU=";
  };
in {
  # see https://github.com/wimpysworld/nix-config/blob/b8a260ddea1bbf088461f7272382d99acbf86ce7/home-manager/_mixins/desktop/pantheon.nix
  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "close,minimize,maximize,appmenu:";
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      favorite-apps = [
        "org.gnome.Settings.desktop"
        "org.gnome.Nautilus.desktop"
        "obsidian.desktop"
        "org.wezfurlong.wezterm.desktop"
        "1password.desktop"
        "signal-desktop.desktop"
        "firefox.desktop"
        "discord.desktop"
        "steam.desktop"
      ];
      enabled-extensions = [
        "trayIconsReloaded@selfmade.pl"
        "dash-to-dock@micxgx.gmail.com"
        "gTile@vibou"
        "search-light@icedman.github.com"
        "quick@web.search"
      ];
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
      intellihide-mode = "ALL_WINDOWS";
      disable-overview-on-startup = true;
    };
    "org/gnome/shell/extensions/trayIconsReloaded" = { icons-limit = 10; };
    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaperImg}";
    };
    "org/gnome/desktop/datetime" = { automatic-timezone = true; };
    "org/gnome/desktop/wm/keybindings" = {
      move-to-monitor-left = [ "<Shift><Control><Alt>h" ];
      move-to-monitor-right = [ "<Shift><Control><Alt>l" ];
      move-to-monitor-up = [ "<Shift><Control><Alt>k" ];
      move-to-monitor-down = [ "<Shift><Control><Alt>j" ];
    };
    "org/gnome/desktop/peripherals/touchpad" = { send-events = "enabled"; };
    "org/gnome/shell/extensions/search-light" = {
      shortcut-search = [ "<Super>space" ];
    };
    "org/gnome/mutter/keybindings" = {
      switch-monitor =
        [ ]; # disable stupid ass default <Super>+p defautl shortcut
    };
  };
}
