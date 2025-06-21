{
  podman_network,
  vuetorrent_port,
  qbittorrent_port,
}:
{ pkgs, isServer, ... }:
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
  }
else
  { }
