{ pkgs, config, ... }: {
  networking.hostName = "nixos-pc";
  imports = [
    ../../nixos-modules/desktop_environment.nix
    ../../nixos-modules/_1password.nix
    ../../nixos-modules/allowed-unfree.nix
    ./hardware-configuration.nix
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  powerManagement.cpuFreqGovernor = "performance";
  hardware = {
    # use proprietary nvidia drivers
    opengl.enable = true;
    nvidia = {
      # workaround for Steam new UI bug, change this back to `config.boot.kernelPackages.nvidiaPackages.stable` in the future.
      # see: https://wiki.archlinux.org/title/Steam/Troubleshooting#Steam_window_does_not_show_on_Nvidia_GPUs_after_the_June_14,_2023_update
      # see last answer here: https://discourse.nixos.org/t/using-older-revisions-of-nvidia-drivers/28645
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      modesetting.enable = true;
      nvidiaPersistenced = true;
    };

    # logitech mouse support
    logitech.wireless = {
      enable = true;
      # installs solaar for configuring mouse buttons
      enableGraphical = true;
    };
  };

  programs = {
    fish.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };

  environment.variables = {
    SUDO_EDITOR = "nvim";
    EDITOR = "nvim";
  };

  environment.systemPackages = with pkgs; [
    steam-run
    steamtinkerlaunch
    parsec-bin
    mullvad-vpn
    prismlauncher
    # dolphinEmu # dolphin build is suuuuper slow and also broken rn
    # rpcs3 # broken right now
  ];
  services.mullvad-vpn.enable = true;

  # for dolphin: https://nixos.wiki/wiki/Dolphin_Emulator
  # boot.extraModulePackages = [ config.boot.kernelPackages.gcadapter-oc-kmod ];

  # to autoload at boot:
  boot.kernelModules = [ "gcadapter_oc" ];
  # services.udev.packages = [ pkgs.dolphinEmu ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
