{
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [
      "kvm-amd"
      "coretemp"
      "rtw89_8851be"
    ];
    extraModulePackages = [ ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/d6f1cc32-5216-43eb-a22c-339f1e0ebabf";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/264C-1D31";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/mnt/storage" = {
      device = "/dev/disk/by-uuid/aad56a7c-b586-4e16-b91f-58fbd796f400";
      fsType = "ext4";
    };
  };

  swapDevices = [ ];
  networking = {
    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    useDHCP = lib.mkDefault true;
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };
  # networking.interfaces.eno2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = "performance";
  powerManagement.powertop.enable = true;

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    enableAllHardware = true;
  };
}
