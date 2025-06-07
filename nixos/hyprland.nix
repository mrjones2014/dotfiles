{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.greetd = {
    enable = true;
    settings.default_session.command = "${lib.getExe config.programs.hyprland.package}";
  };
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  environment.systemPackages = with pkgs; [
    pavucontrol
    hyprsysteminfo
    xdg-desktop-portal-hyprland
  ];
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}
