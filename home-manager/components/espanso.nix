{ isServer, ... }:
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
}
