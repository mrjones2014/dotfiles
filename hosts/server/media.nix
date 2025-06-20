{ config, ... }:
let
  huntarr_port = 9705;
  huntarr_data = "/var/lib/huntarr";
in
{
  imports = [
    ../../nixos/torrent_client.nix
    ./cleanuperr.nix
  ];
  services.nginx.subdomains = {
    # jellyfin doesn't let you configure port via Nix, so just use the default value here
    # see: https://jellyfin.org/docs/general/networking/index.html
    jellyfin.port = 8096;
    jellyseerr.port = config.services.jellyseerr.port;
    prowlarr = {
      inherit (config.services.prowlarr.settings.server) port;
      useLongerTimeout = true;
    };
    sonarr = {
      inherit (config.services.sonarr.settings.server) port;
      useLongerTimeout = true;
    };
    radarr = {
      inherit (config.services.radarr.settings.server) port;
      useLongerTimeout = true;
    };
    bazarr = {
      port = config.services.bazarr.listenPort;
      useLongerTimeout = true;
    };
    huntarr = {
      port = huntarr_port;
      useLongerTimeout = true;
    };
  };
  services = {
    jellyfin.enable = true;
    jellyseerr.enable = true;
    prowlarr.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    bazarr.enable = true;
  };
  # TODO remove this when this is resolved https://github.com/NixOS/nixpkgs/issues/360592
  nixpkgs.config.permittedInsecurePackages = [
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];

  systemd.tmpfiles.rules = [
    "d ${huntarr_data} 0777 root podman -"
  ];
  virtualisation.oci-containers.containers.huntarr = {
    image = "huntarr/huntarr:latest";
    autoStart = true;
    ports = [ "${toString huntarr_port}:${toString huntarr_port}" ];
    volumes = [ "${huntarr_data}:/config" ];
    environment.TZ = "America/New_York";
  };
}
