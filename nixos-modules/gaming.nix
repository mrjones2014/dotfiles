{ pkgs, config, ... }: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    steam-run
    gnomeExtensions.dash-to-dock
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.search-light
  ];

  # use proprietary nvidia drivers
  # some gaming stuff doesn't work good on wayland
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.defaultSession = "gnome-xorg";
  services.xserver.displayManager.gdm.wayland = false;
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaPersistenced = true;

  users.users.mat = { shell = pkgs.fish; };
  nixpkgs.config.firefox.enableGnomeExtensions = true;
}
