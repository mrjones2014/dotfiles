{ inputs, ... }: {
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

  # wezterm binary on server for wezterm ssh
  environment.systemPackages =
    [ inputs.wezterm-nightly.packages.x86_64-linux.default ];

  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
    ./ollama.nix
    ./content.nix
    ./nas.nix
    ./containers.nix
    ./wireguard.nix
    ./gotify.nix
  ];

  powerManagement.cpuFreqGovernor = "performance";
  networking.hostName = "nixos-server";
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
  };
  services = {
    fail2ban.enable = true;
    openssh = {
      enable = true;
      settings = {
        # only allow SSH key auth
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "mat" ];
      };

      ports = [ 6969 ];
    };
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
