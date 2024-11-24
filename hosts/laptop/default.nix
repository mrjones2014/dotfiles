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

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05";
}
