{
  pkgs,
  config,
  isThinkpad,
  isDarwin,
  ...
}:
{
  imports = [ ./zellij.nix ];
  home.packages = [ pkgs.victor-mono ];
  programs.ghostty = {
    enable = true;
    # TODO remove eventually; Ghostty nixpkgs is broken
    # on macOS but I still want to generate the config with nix.
    # I'll install manually on macOS and use Nix to generate the config.
    # For now, shim the package with pkgs.emptyDirectory to trick nix
    # into still generating the config.
    package = if isDarwin then null else pkgs.ghostty;
    installBatSyntax = false;
    clearDefaultKeybinds = true;
    settings = {
      title = "Ghostty";
      font-family = "Victor Mono Semibold";
      font-family-italic = "Victor Mono Medium Oblique";
      font-family-bold-italic = "Victor Mono Bold Oblique";
      font-family-bold = "Victor Mono Bold";
      font-feature = "ss02,ss06";
      font-size = "16";
      cursor-style = "block";
      cursor-style-blink = false;
      macos-option-as-alt = true;
      shell-integration-features = "no-cursor";
      mouse-hide-while-typing = true;
      link-url = true;
      window-decoration = "server";
      # NB: workaround for zellij not having the right PATH on macOS
      command = ''env EDITOR="nvim" PATH="$PATH:/etc/profiles/per-user/${config.home.username}/bin" ${pkgs.zellij}/bin/zellij'';
      maximize = isThinkpad;
      keybind = [
        "super+q=quit"
        "super+v=paste_from_clipboard"
        "super+c=copy_to_clipboard"
      ];
    };
  };
}
