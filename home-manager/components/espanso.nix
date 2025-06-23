{
  lib,
  isServer,
  ...
}:
{
  services.espanso = {
    enable = !isServer;
    configs.default = {
      search_shortcut = "OFF";
      show_notifications = false;
    };
    matches = {
      base = {
        matches = [
          {
            trigger = ":shrug";
            replace = "¯\\_(ツ)_/¯";
          }
          {
            trigger = ":tflip";
            replace = "(╯°□°）╯︵ ┻━┻";
          }

          {
            trigger = ":fingerguns";
            replace = "(☞ ͡° ͜ʖ ͡°)☞";
          }
        ];
      };
    };
  };
  # let espanso set this up itself and use the nix-darwin homebrew installed
  # package, otherwise you have to re-grant accessibility permissions any time
  # home-manager updates the app, but I still want to use home-manager to generate
  # the config files
  launchd.agents.espanso.enable = lib.mkForce false;
}
