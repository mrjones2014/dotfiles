{ pkgs, config, ... }: {
  networking.hostName = "nixos-pc";
  imports = [
    ../../nixos-modules/desktop_environment.nix
    ../../nixos-modules/_1password.nix
    ../../nixos-modules/allowed-unfree.nix
    ../../nixos-modules/sshd.nix
    ./hardware-configuration.nix
  ];
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  powerManagement.cpuFreqGovernor = "performance";
  hardware = {
    # setup udev rules for ZSA keyboard firmware flashing
    keyboard.zsa.enable = true;
    # use proprietary nvidia drivers
    graphics.enable = true;
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = false;
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
      protontricks.enable = true;
      gamescopeSession.enable = true;
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
    wally-cli
    # dolphinEmu # dolphin build is suuuuper slow and also broken rn
    # rpcs3 # broken right now
  ];

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    mullvad-vpn.enable = true;
    tailscale.enable = true;
    flatpak.enable = true;
  };

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
