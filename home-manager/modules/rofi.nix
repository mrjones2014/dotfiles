{ pkgs, config, ... }: {
  programs.rofi = {
    enable = true;
    catppuccin.enable = true;
    plugins = with pkgs; [ rofi-top rofi-calc rofi-power-menu ];
    terminal = "${config.programs.wezterm.package}/bin/wezterm";
    cycle = true;
    extraConfig = { modi = "combi,window,drun,calc"; };
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
