{ isLinux, ... }: {
  services.espanso = {
    enable = isLinux;
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

