{ pkgs, ... }: {
  services.espanso = {
    enable = pkgs.stdenv.isLinux;
    matches = {
      base = {
        matches = [{
          trigger = ":shrug";
          replace = "¯\\_(ツ)_/¯";
        }];
      };
    };
  };
}

