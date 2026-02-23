{ config, ... }:
let
  cleanuparr_port = 11011;
  cleanuparr_data_dir = "/var/lib/cleanuparr";
  cleanuparr_guid = 1432;
in
{
  imports = [ ../../nixos/qbittorrent.nix ];
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
    cleanuparr.port = cleanuparr_port;
  };
  services = {
    jellyfin.enable = true;
    jellyseerr.enable = true;
    prowlarr.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    bazarr.enable = true;
  };

  # cleanuparr
  users = {
    users.cleanuparr = {
      isSystemUser = true;
      group = "cleanuparr";
      uid = cleanuparr_guid;
    };
    groups.cleanuparr.gid = cleanuparr_guid;
  };

  systemd.tmpfiles.rules = [
    "d ${cleanuparr_data_dir} 0750 cleanuparr cleanuparr -"
  ];

  virtualisation.oci-containers.containers.cleanuparr = {
    image = "ghcr.io/cleanuparr/cleanuparr:latest";
    autoStart = true;
    ports = [ "${toString cleanuparr_port}:11011" ];
    volumes = [ "${cleanuparr_data_dir}:/config" ];

    environment = {
      PORT = toString cleanuparr_port;
      PUID = toString config.users.users.cleanuparr.uid;
      PGID = toString config.users.groups.cleanuparr.gid;
      TZ = "Etc/UTC";
    };
  };
}
