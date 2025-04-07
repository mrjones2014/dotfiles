{ pkgs, isThinkpad, isDarwin, ... }: {
  imports = [ ./zellij.nix ];
  home.packages = [ pkgs.victor-mono ];
  programs.ghostty = {
    enable = true;
    # TODO remove eventually; Ghostty nixpkgs is broken
    # on macOS but I still want to generate the config with nix.
    # I'll install manually on macOS and use Nix to generate the config.
    # For now, shim the package with pkgs.emptyDirectory to trick nix
    # into still generating the config.
    package = if isDarwin then pkgs.emptyDirectory else pkgs.ghostty;
    installBatSyntax = false;
    clearDefaultKeybinds = true;
    settings = {
      theme = "tokyonight_night";
      title = "Ghostty";
      "font-family" = "Victor Mono Semibold";
      "font-family-italic" = "Victor Mono Medium Oblique";
      "font-family-bold-italic" = "Victor Mono Bold Oblique";
      "font-feature" = "ss02,ss06";
      "font-size" = "16";
      "window-decoration" = "server";
      "cursor-style" = "block";
      "cursor-style-blink" = false;
      "macos-option-as-alt" = true;
      "link-url" = true;
      "command" = "${pkgs.zellij}/bin/zellij";
      "maximize" = isThinkpad;
    };
  };
}
