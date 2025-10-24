{
  config,
  isServer,
  ...
}:
let
  configDir = "/var/lib/qbittorrentvpn";
  wireguardConfigPath = config.age.secrets.mullvad_wireguard.path;
  qbittorrent_port = 8080;
  tcpPorts = [
    qbittorrent_port
    8118
    9118
    58946
  ];
in
{
  imports = [
    (import ./server.nix { inherit qbittorrent_port; })
    ./desktop.nix
  ];
  boot.kernelModules = [
    "tun"
    "wireguard"
    "iptables_filter"
    "iptables_mangle"
    "iptables_nat"
    "nf_nat"
    "nf_conntrack"
  ];
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
