{ config, pkgs, ... }: {
  programs.wezterm.enable = true;
  # I have my own config
  xdg.configFile."wezterm/wezterm.lua".enable = false;
  home.sessionVariables = { TERM = "wezterm"; };
  xdg.configFile = {
    "wezterm" = {
      source = ../../wezterm;
      recursive = true;
    };
  };
  home.activation.installWeztermTerminfo = ''
    ${pkgs.ncurses}/bin/tic -x -o $HOME/.terminfo ${
      pkgs.fetchurl {
        url =
          "https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo";
        sha256 = "P+mUyBjCvblCtqOmNZlc2bqUU32tMNWpYO9g25KAgNs=";
      }
    }
  '';
}
