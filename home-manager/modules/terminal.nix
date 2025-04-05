{ pkgs, ... }: {
  imports = [ ./zellij.nix ];
  home.packages = [ pkgs.victor-mono ];
  programs = {
    ghostty = {
      enable = true;
      clearDefaultKeybinds = true;
      settings = {
        theme = "tokyonight_night";
        title = "Ghostty";
        "font-family" = "Victor Mono";
        "font-feature" = "ss02,ss06";
        "font-size" = "14";
        "font-style-italic" = "Victor Mono, Semibold Oblique";
        "window-decoration" = "server";
        "cursor-style" = "block";
        "cursor-style-blink" = false;
      };
    };
  };
}
