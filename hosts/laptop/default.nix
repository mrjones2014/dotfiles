{ pkgs, ... }: {
  networking = {
    hostName = "nixos-laptop";
    networkmanager.enable = true;
  };

  imports = [
    ../../nixos-modules/desktop_environment.nix
    ../../nixos-modules/_1password.nix
    ../../nixos-modules/allowed-unfree.nix
    ./hardware-configuration.nix
  ];

  programs = {
    fish.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };

  environment.variables = {
    SUDO_EDITOR = "nvim";
    EDITOR = "nvim";
  };

  services = {
    # Enable the X11 windowing system.
    xserver.enable = true;
    mullvad-vpn.enable = true;
    tailscale.enable = true;
    flatpak.enable = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
