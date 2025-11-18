{ isLinux, isThinkpad, ... }:
if isLinux then
  {
    programs.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = true;
      };
      settings = {
        theme.name = "tokyo-night";
        faviconService = "twenty";
      };
    };
    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "Vicinae";
        binding = if isThinkpad then "<Alt>space" else "<Super>space";
        command = "xdg-open vicinae://toggle";
      };
    };
  }
else
  { }
