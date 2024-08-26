{ pkgs, ... }: {
  config = {
    services = {
      displayManager.defaultSession = "gnome-xorg";
      xserver = {
        enable = true;
        videoDrivers = [ "nvidia" ];
        desktopManager.gnome.enable = true;
        displayManager = { gdm.enable = true; };
      };
    };
    environment = {
      # don't install GNOME crap like Contacts, Photos, etc.
      gnome.excludePackages = with pkgs; [
        gnome-photos
        gnome-tour
        cheese # webcam tool
        epiphany # web browser
        geary # email reader
        yelp # Help view
        seahorse # password/ssh manager, I use 1Password SSH
        gnome-calendar
        gnome-music
        gnome-characters
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        gnome-contacts
        gnome-initial-setup
      ];
    };

    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
    programs.dconf.enable = true;
  };
}
