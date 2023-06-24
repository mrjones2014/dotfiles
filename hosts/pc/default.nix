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
    prismlauncher
    dolphinEmu
  ];
  services.mullvad-vpn.enable = true;

  # for dolphin: https://nixos.wiki/wiki/Dolphin_Emulator
  boot.extraModulePackages = [ config.boot.kernelPackages.gcadapter-oc-kmod ];

  # to autoload at boot:
  boot.kernelModules = [ "gcadapter_oc" ];
  services.udev.packages = [ pkgs.dolphinEmu ];
}
