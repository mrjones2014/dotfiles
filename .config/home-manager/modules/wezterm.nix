{
  programs.wezterm.enable = true;
  # I have my own config
  xdg.configFile."wezterm/wezterm.lua".enable = false;
  home.sessionVariables = { TERM = "wezterm"; };
}
