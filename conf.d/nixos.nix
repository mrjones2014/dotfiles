{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    steam-run
    gnomeExtensions.dash-to-dock
    albert
  ];

  users.users.mat = { shell = pkgs.fish; };
  nixpkgs.config.firefox.enableGnomeExtensions = true;
}
