let
  dashdotPort = 9090;
  uptimeKumaPort = 3001;
in {
  networking.firewall = {
    allowedTCPPorts = [ dashdotPort uptimeKumaPort ];
    allowedUDPPorts = [ dashdotPort uptimeKumaPort ];
  };
  services.uptime-kuma = {
    enable = true;
    settings.HOST = import ./ip.nix;
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
