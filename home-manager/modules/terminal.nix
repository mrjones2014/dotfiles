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
        "font-family-italic" = "Victor Mono Oblique";
        "font-family-bold-italic" = "Victor Mono Bold Oblique";
        "font-feature" = "ss02,ss06";
        "font-size" = "14";
        "window-decoration" = "server";
        "cursor-style" = "block";
        "cursor-style-blink" = false;
        "macos-option-as-alt" = true;
      };
    };
  };
}
