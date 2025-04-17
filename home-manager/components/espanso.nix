{ isLinux, ... }: {
  services.espanso = {
    enable = isLinux;
    configs.default.search_shortcut = "OFF";
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

