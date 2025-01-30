{ pkgs, lib, isThinkpad, ... }:
let
  monitor_config = pkgs.writeText "gdm_monitors.xml"
    (builtins.readFile ../conf.d/gnome-monitors.xml);
in {
  nixpkgs.overlays = [
    # GNOME 46: triple-buffering-v4-46
    # See:
    # - https://nixos.wiki/wiki/GNOME#Dynamic_triple_buffering
    # - https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1441
    (final: prev: {
      gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
        mutter = gnomePrev.mutter.overrideAttrs (old: {
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.gnome.org";
            owner = "vanvugt";
            repo = "mutter";
            rev = "triple-buffering-v4-46";
            hash = "sha256-C2VfW3ThPEZ37YkX7ejlyumLnWa9oij333d5c4yfZxc=";
          };
        });
      });
    })
  ];

  services = {
    gnome.gnome-keyring.enable = true;
    displayManager.defaultSession = "gnome-xorg";
    xserver = {
      enable = true;
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
} // lib.attrsets.optionalAttrs (!isThinkpad) {
  # make GDM use the same monitor config as GNOME;
  # see: https://discourse.nixos.org/t/set-external-monitor-as-primary-display-before-login/37844/4
  systemd.tmpfiles.rules =
    [ "L+ /run/gdm/.config/monitors.xml - - - - ${monitor_config}" ];
}
