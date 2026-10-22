{ config, pkgs, ... }:
{
  imports = [
    ../../nixos/desktop_environment.nix
    ../../nixos/nixpkgs-config.nix
    ../../nixos/ssh-server.nix
    ../../nixos/containers.nix
    ./hardware-configuration.nix
  ];

  dotfiles = {
    _1password.enable = true;
    unfree.packageNames = [
      "1password-cli"
      "claude-code"
      "7zz"
      "discord"
      "discord-unwrapped"
      "parsec-bin"
      "rectangle-pro"
      "spotify"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
    ];
    qbittorrent = {
      enable = true;
      dataDir = "/mnt/storage/downloads";
      namespaceAddress = "192.168.15.2";
      namespaceAddressIPv6 = "fd93:9701:1d00::3";
      wireguardConfigFile = ../../secrets/proton_wireguard_conf_desktop.age;
      sessionSettings.GlobalMaxSeedingMinutes = 0;
    };
  };

  networking.hosts."${config.dotfiles.qbittorrent.namespaceAddress}" = [ "qbittorrent.lan" ];
  boot = {
    kernelPackages = pkgs.linuxPackages_latest; # ensure latest kernel for hardware support
    loader.efi.efiSysMountPoint = "/boot";

    # for dolphin: https://nixos.wiki/wiki/Dolphin_Emulator
    # boot.extraModulePackages = [ config.boot.kernelPackages.gcadapter-oc-kmod ];
  };
  powerManagement.cpuFreqGovernor = "performance";
  hardware = {
    firmware = [ pkgs.linux-firmware ]; # ensure latest firmware
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    keyboard = {
      # setup udev rules for keyboard firmware flashing
      zsa.enable = true;
      qmk = {
        enable = true;
        keychronSupport = true;
      };
    };
  };

  programs = {
    fish.enable = true;
    # coolercontrol.enable = true;
    gamemode.enable = true;
    gamescope.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      protontricks.enable = true;
      gamescopeSession.enable = true;
    };
  };

  environment.variables = {
    SUDO_EDITOR = "nvim";
    EDITOR = "nvim";
  };

  environment.systemPackages = with pkgs; [
    steam-run
    winetricks
    steamtinkerlaunch
    parsec-bin
    prismlauncher
    protonup-qt
    godot

    ## broken packages :(
    # dolphin-emu
    # rpcs3
  ];

  services = {
    xserver.enable = true;
    flatpak.enable = true;
  };
  # services.udev.packages = [ pkgs.dolphinEmu ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
