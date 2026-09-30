{
  pkgs,
  isDarwin,
  isWorkMac,
  ...
}:
{
  home.packages = [ pkgs.victor-mono ];
  programs.ghostty = {
    enable = true;
    # GUI apps are installed via nix-darwin brew on macOS
    package = if isDarwin then null else pkgs.ghostty;
    installBatSyntax = false;
    clearDefaultKeybinds = true;
    settings = {
      adjust-cell-height = "4%";
      font-family = "Victor Mono Semibold";
      font-family-italic = "Victor Mono Medium Oblique";
      font-family-bold-italic = "Victor Mono Bold Oblique";
      font-family-bold = "Victor Mono Bold";
      font-feature = [
        "ss02"
        "ss06"
      ];
      font-size = "16";
      copy-on-select = "clipboard";
      cursor-style = "block";
      cursor-style-blink = false;
      macos-option-as-alt = true;
      shell-integration-features = "no-cursor";
      mouse-hide-while-typing = true;
      link-url = true;
      link-previews = true;
      window-decoration = "server";
      window-padding-balance = true;
      window-padding-x = 0;
      window-padding-y = 0;
      maximize = isDarwin && !isWorkMac;
      # tmux owns tabs and splits; this is a single window that runs it. Notably
      # absent is `super+n=new_window`: a second Ghostty window would attach a
      # mirrored client to the same tmux session, clamped to the smaller size.
      keybind = [
        "super+q=quit"
        "super+v=paste_from_clipboard"
        "super+c=copy_to_clipboard"
      ];
    };
  };
}
