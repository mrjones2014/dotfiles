{ pkgs, ... }: {
  programs.rofi = {
    enable = true;
    plugins = with pkgs; [ rofimoji rofi-top rofi-calc rofi-power-menu ];
  };
}
