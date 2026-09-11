{
  pkgs,
  isThinkpad,
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
      adjust-cell-height = "6%";
      font-family = "Victor Mono Semibold";
      font-family-italic = "Victor Mono Medium Oblique";
      font-family-bold-italic = "Victor Mono Bold Oblique";
      font-family-bold = "Victor Mono Bold";
      font-feature = [
        "ss02"
        "ss06"
      ];
      font-size = "16";
      cursor-style = "block";
      cursor-style-blink = false;
      macos-option-as-alt = true;
      shell-integration-features = "no-cursor";
      mouse-hide-while-typing = true;
      link-url = true;
      link-previews = true;
      window-decoration = "server";
      maximize = isThinkpad || (isDarwin && !isWorkMac);
      keybind = [
        # Window
        "super+q=quit"
        "super+v=paste_from_clipboard"
        "super+c=copy_to_clipboard"
        "super+n=new_window"

        # Split navigation (performable: delegate to Neovim first via smart-splits)
        "performable:ctrl+h=goto_split:left"
        "performable:ctrl+j=goto_split:down"
        "performable:ctrl+k=goto_split:up"
        "performable:ctrl+l=goto_split:right"

        # Split resize
        "performable:alt+h=resize_split:left,30"
        "performable:alt+j=resize_split:down,30"
        "performable:alt+k=resize_split:up,30"
        "performable:alt+l=resize_split:right,30"

        # New splits
        "super+h=new_split:left"
        "super+l=new_split:right"
        "super+j=new_split:down"
        "super+k=new_split:up"

        # Tabs
        "alt+n=new_tab"
        "alt+left=previous_tab"
        "alt+right=next_tab"
      ];
    };
  };
}
