{ lib, pkgs, config, ... }: {
  imports = [ ./hardware-configuration.nix ];
  powerManagement.cpuFreqGovernor = "performance";
  programs.fish.enable = true;
  users.users.mat.shell = pkgs.fish;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # use proprietary nvidia drivers
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # these are needed for Wayland to work
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaPersistenced = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.variables = {
    SUDO_EDITOR = "nvim";
    EDITOR = "nvim";
  };

  environment.systemPackages = with pkgs; [
    steam-run
    parsec-bin
    mullvad-vpn
    minecraft
  ];
  services.mullvad-vpn.enable = true;
}
