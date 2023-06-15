{ pkgs, ... }: {
  config = {
    environment.systemPackages = [ pkgs.pantheon.elementary-dock ];
    programs.dconf.enable = true;
    services.xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      desktopManager.pantheon.enable = true;
      displayManager.lightdm = {
        enable = true;
        greeters.pantheon.enable = true;
      };
    };
    environment.pantheon.excludePackages = with pkgs.pantheon; [
      appcenter
      elementary-calculator
      elementary-calendar
      elementary-camera
      elementary-code
      elementary-feedback
      elementary-mail
      elementary-music
      elementary-photos
      elementary-tasks
      elementary-videos
    ];
  };
}
