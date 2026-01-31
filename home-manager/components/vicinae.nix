{ isLinux, isThinkpad, ... }:
if isLinux then
  {
    programs.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = true;
      };
      # easiest way to find these keys is:
      # ```bash
      # VICINAE_CFG_PATH=$(readlink ~/.config/vicinae/settings.json) \
      #   rm ~/.config/vicinae/settings.json && \
      #   cp $VICINAE_CFG_PATH ~/.config/vicinae/
      # ```
      # Then change settings through GUI,
      # copy the modified settings back into here,
      # and rebuild.
      settings = {
        close_on_focus_loss = true;
        pop_to_root_on_close = true;
        theme.name = "tokyo-night";
        faviconService = "twenty";
        fallbacks = [ "shortcuts:kagi" ];
        providers = {
          core.entrypoints.sponsor.enabled = false;
          applications = {
            enabled = true;
            preferences.defaultAction = "focus";
          };
        };
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
