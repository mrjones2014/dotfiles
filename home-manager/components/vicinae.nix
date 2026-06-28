{
  inputs,
  lib,
  pkgs,
  isThinkpad,
  isLinux,
  ...
}:
{
  imports = [ inputs.vicinae.homeManagerModules.default ];
  config = lib.mkIf isLinux {
    programs.vicinae = {
      enable = true;
      # Use nixpkgs version; the project's flake provides a better
      # home-manager module though
      package = pkgs.vicinae;
      systemd = {
        enable = true;
        autoStart = true;
      };
      # easiest way to find these keys is to just
      # change settings through GUI, then copy
      # the relevant keys from the main config file
      # back into here.
      settings = {
        close_on_focus_loss = true;
        pop_to_root_on_close = true;
        theme.name = "tokyo-night";
        faviconService = "twenty";
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
  };
}
