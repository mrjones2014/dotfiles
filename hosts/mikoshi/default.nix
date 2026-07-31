{
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
    ./nixosModules/nginx.nix
    ./media.nix
    ./nas.nix
    ./observability.nix
    ./paperless.nix
    ./adguard.nix
    ./homeassistant.nix
    ./scrypted.nix
    ../../nixos/ssh-server.nix
    ../../nixos/containers.nix
    ../../nixos/nixpkgs-config.nix
  ];

  powerManagement.cpuFreqGovernor = "performance";

  # ipv6 stuff for Matter over Thread
  networking.enableIPv6 = true;
  boot = {
    kernel.sysctl = {
      # ipv6 stuff for Matter over Thread
      "net.ipv6.conf.enp0s31f6.accept_ra" = 2;
      "net.ipv6.conf.enp0s31f6.accept_ra_rt_info_max_plen" = 64;
      # less aggressive swap usage
      "vm.swappiness" = 25;
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
  };

  # enable vaapi on OS-level
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  programs = {
    fish.enable = true;
    dconf.enable = true; # TODO this shouldn't be needed but home-manager complains without it
  };
}
