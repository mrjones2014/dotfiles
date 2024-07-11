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
      gnome.excludePackages = (with pkgs; [
        gnome-photos
        gnome-tour
        cheese # webcam tool
        epiphany # web browser
        geary # email reader
        yelp # Help view
        seahorse # password/ssh manager, I use 1Password SSH
        gnome-calendar
      ]) ++ (with pkgs.gnome; [
        gnome-music
        gnome-characters
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        gnome-contacts
        gnome-initial-setup
      ]);

      systemPackages = with pkgs.gnomeExtensions; [
        dash-to-dock
        tray-icons-reloaded
        gtile
        search-light
        quick-web-search
        user-themes
      ];
    };

    programs.dconf.enable = true;
  };
}
