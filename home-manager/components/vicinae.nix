{
  config,
  lib,
  pkgs,
  isLinux,
  isThinkpad,
  ...
}:
if isLinux then
  let
    mkMutableJsonConfig = import ../../lib/mutable-json-config.nix { inherit config lib pkgs; };
  in
  {
    programs.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = true;
      };
    };
    # easiest way to find these keys is to just
    # change settings through GUI, then copy
    # the relevant keys from the config file
    # back into here.
    # Vicinae expects its config to be writable,
    # so we merge the existing config file (if it exists)
    # with our nix-managed settings
    imports = [
      (mkMutableJsonConfig {
        name = "vicinae";
        target = "vicinae/settings.json";
        managed = {
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
      })
    ];
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
