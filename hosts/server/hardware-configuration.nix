{
  pkgs,
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot = {
    initrd = {
      luks.devices = {
        "cryptroot" = {
          device = "/dev/disk/by-partlabel/root"; # Use partition label, not filesystem label
          preLVM = true;
        };

        "cryptswap" = {
          device = "/dev/disk/by-partlabel/swap"; # Partition label for swap
          preLVM = true;
        };
      };

      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sr_mod"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
        "uid=0"
        "gid=0"
      ];
    };
    "/mnt/fileshare" = {
      device = "/dev/disk/by-label/fileshare";
      fsType = "ext4";
    };
    "/export/fileshare" = {
      device = "/mnt/fileshare";
      options = [ "bind" ];
    };
    "/mnt/jellyfin" = {
      device = "/dev/disk/by-label/media";
      fsType = "ext4";
    };
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
  networking = {
    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    useDHCP = lib.mkDefault true;
    hostName = "homelab";
    defaultGateway = "192.168.1.1";
    nameservers = [
      # TODO temporary. Works around a stupid ass issue with AmpliFi router.
      # Remove when I get my new UniFi router replacement.
      "127.0.0.1"
      config.networking.defaultGateway.address
    ];
    # static IP on ethernet interface
    interfaces.enp0s31f6.ipv4.addresses = [
      {
        address = import ./ip.nix;
        prefixLength = 24;
      }
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # enable hardware transcoding stuff for jellyfin
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver # previously vaapiIntel
      vaapiVdpau
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      vpl-gpu-rt # QSV on 11th gen or newer
    ];
  };
}
