{ pkgs, ... }: {
  networking.hostName = "nixos-server";
  services = {
    openssh = {
      # only allow SSH key auth
      passwordAuthentication = false;
      permitRootLogin = "no";
      ports = [ 6969 ];
    };

    jellyfin = {
      enable = true;
      # see: https://jellyfin.org/docs/general/networking/index.html
      # ports are:
      # TCP: 8096, 8920
      # UDP: 1900 7359
      openFirewall = true;
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

  users = {
    mutableUsers = false;
    users = {
      mat = {
        shell = pkgs.fish;
        isNormalUser = true;
        # generated via: nix-shell -p pkgs.openssl --run "openssl passwd -1"
        hashedPassword = "$1$kWL6uedh$2zhN6tfwSD8dhWG5jONJK.";
        home = "/home/mat";
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsT6GLG7sY8YKX7JM+jqS3EAti3YMzwHKWViveqkZvu"
        ];
      };
    };
  };
}
