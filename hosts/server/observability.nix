{ config, ... }:
let
  homarrStateDir = "/var/lib/homarr";
  homarrPort = 9090;
  dashdotPort = 9091;
  uptimeKumaPort = 3001;
in
{
  networking.firewall = {
    allowedTCPPorts = [ homarrPort dashdotPort uptimeKumaPort ];
    allowedUDPPorts = [ homarrPort dashdotPort uptimeKumaPort ];
  };

  services.uptime-kuma = {
    enable = true;
    settings.HOST = import ./ip.nix;
  };

  systemd.tmpfiles.rules = [ "d ${homarrStateDir} 0750 root root -" ];
  age.secrets.homarr_env.file = ../../secrets/homarr_env.age;
  virtualisation.oci-containers.containers.homarr = {
    autoStart = true;
    image = "ghcr.io/homarr-labs/homarr:latest";
    ports = [ "${builtins.toString homarrPort}:7575" ];
    volumes = [ "${homarrStateDir}:/appdata" ];
    environmentFiles = [ config.age.secrets.homarr_env.path ];
  };

  virtualisation.oci-containers.containers.dashdot = {
    image = "mauricenino/dashdot";
    ports = [ "${builtins.toString dashdotPort}:3001" ];
    volumes = [ "/:/mnt/host:ro" ];
    extraOptions = [ "--privileged=true" ];
    environment = {
      DASHDOT_PAGE_TITLE = "Dashboard";
      DASHDOT_USE_IMPERIAL = "true";
      DASHDOT_ALWAYS_SHOW_PERCENTAGES = "true";
      DASHDOT_OVERRIDE_OS = "NixOS";
      DASHDOT_OVERRIDE_ARCH = "x86";
      DASHDOT_CUSTOM_HOST = "nixos-server";
      DASHDOT_SHOW_HOST = "true";
    };
  };
}
