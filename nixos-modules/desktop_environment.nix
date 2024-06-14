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
      gnome.excludePackages = (with pkgs; [ gnome-photos gnome-tour ])
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
          seahorse # password/ssh manager
          gnome-contacts
          gnome-calendar
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
