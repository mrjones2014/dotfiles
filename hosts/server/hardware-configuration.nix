{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot = {

    initrd.availableKernelModules =
      [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/1d1ea430-2313-4753-a4b2-d20923e375a2";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/FC16-1546";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
    "/mnt/jellyfin" = {
      device = "/dev/disk/by-uuid/03606b53-5d7c-4e68-b729-9615d100c902";
      fsType = "ext4";
    };
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/68daba82-d50d-4269-884d-68d1b1fe7b88"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
