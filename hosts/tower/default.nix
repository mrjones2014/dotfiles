{ pkgs, ... }:
{
  networking.hostName = "tower";
  imports = [
    ../../nixos/desktop_environment.nix
    ../../nixos/_1password.nix
    ../../nixos/nixpkgs-config.nix
    ../../nixos/sshd.nix
    ../../nixos/containers.nix
    ../../nixos/torrent_client
    ./macos-style-keymap.nix
    ./hardware-configuration.nix
  ];
  boot.loader.efi.efiSysMountPoint = "/boot";
  powerManagement.cpuFreqGovernor = "performance";
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # setup udev rules for ZSA keyboard firmware flashing
    keyboard.zsa.enable = true;

    # logitech mouse support
    logitech.wireless = {
      enable = true;
      # installs solaar for configuring mouse buttons
      enableGraphical = true;
    };

  };

  programs = {
    fish.enable = true;
    coolercontrol.enable = true;
    gamemode.enable = true;
    gamescope.enable = true;
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
    winetricks
    steamtinkerlaunch
    parsec-bin
    mullvad-vpn
    prismlauncher
    wally-cli
    protonup-qt
    dolphin-emu
    # rpcs3 # broken right now
  ];

  services = {
    xserver.enable = true;
    mullvad-vpn.enable = true;
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
