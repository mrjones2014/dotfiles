{
  config,
  lib,
  pkgs,
  isServer,
  ...
}:
let
  configDir = "/var/lib/qbittorrentvpn";
  wireguardConfigPath = config.age.secrets.mullvad_wireguard.path;
  qbittorrent_port = 8080;
  vuetorrent_port = 8081;
  tcpPorts = [
    qbittorrent_port
    8118
    9118
    58946
  ];
  podman_network = "qbittorrent";
in
lib.optionalAttrs isServer {
  services.nginx.subdomains = {
    qbittorrent.port = qbittorrent_port;
    vuetorrent.port = vuetorrent_port;
    age.secrets.mullvad_wireguard.file = ../secrets/mullvad_wireguard.age;
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
// lib.optionalAttrs (!isServer) {
  age.secrets.mullvad_wireguard.file = ../secrets/mullvad_wireguard_desktop.age;
}
// {
  systemd.tmpfiles.rules = [
    "d ${configDir} 055 qbittorrentvpn qbittorrentvpn - -"
    "d ${configDir}/wireguard 055 qbittorrentvpn qbittorrentvpn - -"
  ];
  system.activationScripts.copyWireguardConfigIntoContainer.text = ''
    mkdir -p ${configDir}/wireguard && cp ${wireguardConfigPath} ${configDir}/wireguard/mullvad_wireguard.conf
  '';

  virtualisation.oci-containers.containers.qbittorrentvpn = {
    autoStart = true;
    image = "ghcr.io/binhex/arch-qbittorrentvpn";
    extraOptions = [
      "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
      "--privileged=true"
    ];
    ports = builtins.map (port: "${builtins.toString port}:${builtins.toString port}") tcpPorts;
    volumes = [
      (if isServer then "/mnt/jellyfin:/data" else "/mnt/storage/OtherGames:/data")
      "${configDir}:/config"
      "/etc/localtime:/etc/localtime:ro"
    ];
    environment = {
      VPN_ENABLED = "yes";
      VPN_PROV = "custom";
      VPN_CLIENT = "wireguard";
      USERSPACE_WIREGUARD = "no";
      STRICT_PORT_FORWARD = "yes";
      ENABLE_PRIVOXY = "yes";
      LAN_NETWORK = "192.168.1.0/24";
      NAME_SERVERS = "1.1.1.1,1.0.0.1";
      ENABLE_STARTUP_SCRIPTS = "yes";
      ENABLE_SOCKS = "yes";
      VPN_INPUT_PORTS = "";
      VPN_OUTPUT_PORTS = "";
      DEBUG = "false";
      UMASK = "000";
      PUID = "0";
      PGID = "0";
    };
  };
}
