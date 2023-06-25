{ pkgs, lib, ... }:
let
  vars = (import ../vars.nix);
  usePantheon = vars.usePantheon;
  useGnome = vars.useGnome;
in {
  config = { } // lib.optionalAttrs useGnome {
    services.xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      desktopManager.gnome.enable = true;
      displayManager = {
        defaultSession = "gnome-xorg";
        gdm.enable = true;
      };
    };

    # don't install GNOME crap like Contacts, Photos, etc.
    environment.gnome.excludePackages = (with pkgs; [ gnome-photos gnome-tour ])
      ++ (with pkgs.gnome; [
        cheese # webcam tool
        gnome-music
        gedit # text editor
        epiphany # web browser
        geary # email reader
        gnome-characters
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        yelp # Help view
        gnome-contacts
        gnome-initial-setup
      ]);

    programs.dconf.enable = true;
    environment.systemPackages = with pkgs.gnomeExtensions; [
      dash-to-dock
      tray-icons-reloaded
      search-light
      no-overview
      gtile
    ];
  } // lib.optionalAttrs usePantheon {
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
