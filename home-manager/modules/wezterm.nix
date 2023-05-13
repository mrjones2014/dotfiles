{ config, pkgs, ... }: {
  programs.wezterm.enable = true;
  # I have my own config
  xdg.configFile."wezterm/wezterm.lua".enable = false;
  xdg.desktopEntries."org.wezfurlong.wezterm" = {
    name = "Wezterm";
    exec =
      if pkgs.stdenv.isLinux then ''"nixGL wezterm || wezterm"'' else "wezterm";
    icon = "org.wezfurlong.wezterm";
    settings = {
      Keywords = "shell;prompt;command;commandline;cmd";
      StartupWMClass = "org.wezfurlong.wezterm";
    };
  };
  home.sessionVariables = { TERM = "wezterm"; };
  home.file."${config.xdg.configHome}/wezterm" = {
    source = ../../wezterm;
    recursive = true;
  };
}
