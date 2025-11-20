# verify that qbittorrent is running inside the network namespace with
#
# ps aux | grep qbittorrent # find the PID of qbittorrent
# sudo ip netns identify <PID> # it should output qbt-wg
#
# verify that the network namespace is behind the VPN with
#
# sudo ip netns exec qbt-wg curl https://am.i.mullvad.net/connected
{
  config,
  lib,
  inputs,
  isServer,
  ...
}:
let
  data_dir = if isServer then "/mnt/jellyfin" else "/mnt/storage/torrents";
  qbittorrent_port = 8080;
  network_namespace = "qbt-wg";
  mullvad_secret_file =
    if isServer then ../secrets/mullvad_wireguard.age else ../secrets/mullvad_wireguard_desktop.age;
in
{
  imports = [ inputs.vpn-confinement.nixosModules.default ];
  age.secrets.mullvad_wireguard.file = mullvad_secret_file;
  vpnNamespaces.${network_namespace} = {
    enable = true;
    wireguardConfigFile = config.age.secrets.mullvad_wireguard.path;
    accessibleFrom = [
      "192.168.1.0/24"
    ];
    portMappings = [
      {
        from = qbittorrent_port;
        to = qbittorrent_port;
        protocol = "tcp";
      }
    ];
  };
  services.qbittorrent = {
    enable = true;
    openFirewall = false;
    webuiPort = qbittorrent_port;
    serverConfig = {
      Core.AutoDeleteAddedTorrentFile = "Never";
      Preferences.Connection = {
        WebUI.LocalHostAuth = false;
      };
      BitTorrent.Session = {
        DefaultSavePath = "${data_dir}/media";
        TempPath = "${data_dir}/incomplete";
        TempPathEnabled = true;
        AnonymousModeEnabled = true;
        GlobalMaxSeedingMinutes = -1;
      };
    };
  };
  systemd.services.qbittorrent.vpnConfinement = {
    enable = true;
    vpnNamespace = network_namespace;
  };
}
// lib.optionalAttrs isServer {
  services.nginx.subdomains.qbittorrent = {
    address = config.vpnNamespaces.${network_namespace}.namespaceAddress;
    port = qbittorrent_port;
  };
}
// lib.optionalAttrs (!isServer) {
  networking.hosts."${config.vpnNamespaces.${network_namespace}.namespaceAddress}" = [
    "qbittorrent.lan"
  ];
}
