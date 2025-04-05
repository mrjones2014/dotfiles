{
  xdg.configFile."zellij/config.kdl".source = ../../conf.d/config.kdl;
  programs = {
    zellij = {
      enable = true;
      enableFishIntegration = true;
    };
    ghostty = {
      enable = true;
      clearDefaultKeybinds = true;
      settings.theme = "tokyonight_night";
    };
  };
}
