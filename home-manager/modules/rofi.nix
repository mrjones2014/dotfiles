{ pkgs, config, isLinux, ... }: {
  programs.rofi = {
    enable = isLinux;
    plugins = with pkgs; [ rofi-top rofi-calc rofi-power-menu ];
    terminal = "${config.programs.wezterm.package}/bin/wezterm";
    cycle = true;
    extraConfig = {
      modi = "combi,window,drun,calc";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      location = 0;
      disable-history = false;
      sidebar-mode = false;
      display-drun = " ";
      display-run = " ";
      display-combi = " ";
      display-window = " ";

      # vim keymaps
      kb-row-up = "Control+p";
      kb-row-down = "Control+n";

      # general settings
      matching = "normal";
      tokenize = true;
      drun-categories = "";
      drun-match-fields = "name,generic,exec,categories,keywords";
      drun-display-format = "{icon} {name}";
      window-format = "{icon} {name}";
      combi-display-format = "{mode} {icon} {name}";

      drun-show-actions = false;
      drun-url-launcher = "xdg-open";
      drun-use-desktop-cache = false;
      drun-reload-desktop-cache = false;
      drun-parse-user = true;
      drun-parse-system = true;
      combi-modi = "window,drun";
      combi-hide-mode-prefix = true;
    };
  };
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
      terminal = "";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
      {
        binding = "<Super>space";
        command = "rofi -show combi";
        name = "rofi";
      };
  };
}
