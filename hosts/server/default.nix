{ ... }: {
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
  system.stateVersion = "23.11";

  imports = [
    ./hardware-configuration.nix
    ./nginx.nix
    ./content.nix
    ./nas.nix
    ./containers.nix
    ./wireguard.nix
    ./observability.nix
    ./vikunja.nix
    ./trilium.nix
    ./duckdns.nix
    ../../nixos/sshd.nix
  ];

  powerManagement.cpuFreqGovernor = "performance";
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # enable vaapi on OS-level
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  programs = {
    fish.enable = true;
    dconf.enable =
      true; # TODO this shouldn't be needed but home-manager complains without it
  };
}
