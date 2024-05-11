{ pkgs, ... }: {
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
    ./secrets.nix
    ./ollama.nix
    ./nginx.nix
    ./content.nix
    ./nas.nix
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
  services = { # Did you read the comment?
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
      extraConfig = ''
        AcceptEnv WEZTERM_REMOTE_PANE
      '';
    };
  };

  # enable vaapi on OS-level
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
    ];
  };
  programs.fish.enable = true;
}
