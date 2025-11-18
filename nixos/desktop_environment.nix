{ pkgs, ... }:
{
  # Make electron apps detect wayland properly
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  services = {
    displayManager.cosmic-greeter.enable = true;
    desktopManager.cosmic.enable = true;
  };

  environment.cosmic.excludePackages = with pkgs; [
    cosmic-player
    cosmic-edit
    cosmic-term
    cosmic-store
  ];

  programs.dconf.enable = true;
}
