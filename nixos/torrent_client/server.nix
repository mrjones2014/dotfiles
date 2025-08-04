{
  podman_network,
  vuetorrent_port,
  qbittorrent_port,
}:
{
  pkgs,
  isServer,
  config,
  ...
}:
if isServer then
  {
    age.secrets.mullvad_wireguard.file = ../../secrets/mullvad_wireguard.age;
    services.nginx.subdomains = {
      qbittorrent.port = qbittorrent_port;
      vuetorrent.port = vuetorrent_port;
    };
    systemd.services.qbittorrent-podman-network-create = {
      serviceConfig.Type = "oneshot";
      wantedBy = [
        "podman-qbittorrentvpn.service"
        "podman-vuetorrent.service"
      ];
      script = ''
        ${pkgs.podman}/bin/podman network inspect ${podman_network} > /dev/null 2>&1 || ${pkgs.podman}/bin/podman network create ${podman_network}
      '';
    };
    virtualisation.oci-containers.containers.qbittorrentvpn.networks = [ podman_network ];
    # prettier web UI
    virtualisation.oci-containers.containers.vuetorrent = {
      autoStart = true;
      image = "ghcr.io/vuetorrent/vuetorrent-backend:latest";
      networks = [ podman_network ];
      ports = [ "${toString vuetorrent_port}:${toString vuetorrent_port}" ];
      environment = {
        PORT = toString vuetorrent_port;
        QBIT_BASE = "http://qbittorrentvpn:${toString qbittorrent_port}";
        RELEASE_TYPE = "stable";
        # every Sunday
        UPDATE_VT_CRON = "0 0 * * 0";
      };
    };
    age.secrets.cross-seed-cfg.file = ../../secrets/cross_seed_cfg.age;
    services.cross-seed = {
      enable = true;
      # this gets merged with the `settings` nixos option
      settingsFile = config.age.secrets.cross-seed-cfg.path;
      settings = {
        host = "127.0.0.1";
        action = "inject";
        useClientTorrents = true;
        matchMode = "partial";
        seasonFromEpisodes = 0.5;
        linkDirs = [
          "/mnt/jellyfin/incomplete/cross-seed"
          "/mnt/jellyfin/media/cross-seed"
        ];
        outputDir = "/mnt/jellyfin/torrents/cross-seed";
        duplicateCategories = true;
      };
    };
  }
else
  { }
