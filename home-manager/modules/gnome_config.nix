{ pkgs, ... }:
let
  autostartPrograms =
    if pkgs.stdenv.isDarwin then [ ] else [ pkgs._1password-gui ];
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

  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "close,minimize,maximize,appmenu:";
    };
    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Settings.desktop"
        "org.gnome.Nautilus.desktop"
        "org.wezfurlong.wezterm.desktop"
        "1password.desktop"
        "signal-desktop.desktop"
        "librewolf.desktop"
        "steam.desktop"
      ];
      enabled-extensions = [
        "trayIconsReloaded@selfmade.pl"
        "search-light@icedman.github.com"
        "dash-to-dock@micxgx.gmail.com"
        "no-overview@fthx"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      clock-show-weekday = true;
    };
  };
}
