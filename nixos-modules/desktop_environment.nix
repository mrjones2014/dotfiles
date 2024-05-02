{ pkgs, ... }: {
  config = {
    services.displayManager.defaultSession = "gnome-xorg";
    services.xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      desktopManager.gnome.enable = true;
      displayManager = { gdm.enable = true; };
    };

    # don't install GNOME crap like Contacts, Photos, etc.
    environment.gnome.excludePackages = (with pkgs; [ gnome-photos gnome-tour ])
      ++ (with pkgs.gnome; [
        cheese # webcam tool
        gnome-music
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
      no-overview
      gtile
    ];
  };
}
