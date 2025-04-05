{
  imports = [ ./zellij.nix ];
  programs = {
    ghostty = {
      enable = true;
      clearDefaultKeybinds = true;
      settings = {
        theme = "tokyonight_night";
        title = "Ghostty";
      };
    };
  };
}
