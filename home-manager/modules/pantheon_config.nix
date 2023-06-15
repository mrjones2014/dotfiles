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
    "org/pantheon/desktop/gala/appearance" = {
      button-layout = "close,minimize,maximize,appmenu:";
    };
  };
}
