{
  isLinux,
  pkgs,
  lib,
  ...
}:
lib.optionalAttrs isLinux {
  xdg.dataFile."icons/discord.png".source = ./discord.png;
  home.packages = [
    # vesktop discord client, I don't like
    # vesktop's icon, so override it
    (pkgs.vesktop.overrideAttrs (oldAttrs: {
      desktopItems = [
        (pkgs.makeDesktopItem {
          name = "vesktop";
          desktopName = "Discord";
          exec = "vesktop %U";
          icon = "discord";
          startupWMClass = "Vesktop";
          genericName = "Internet Messenger";
          keywords = [
            "discord"
            "vencord"
            "electron"
            "chat"
          ];
          categories = [
            "Network"
            "InstantMessaging"
            "Chat"
          ];
        })
      ];
    }))
  ];
}
