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
  data_dir = if isServer then "/mnt/jellyfin" else "/mnt/storage/downloads";
  qbittorrent_port = 8080;
  network_namespace = "qbt-wg";
  namespace_address = if isServer then "192.168.15.1" else "192.168.15.2";
  namespace_address_v6 = if isServer then "fd93:9701:1d00::2" else "fd93:9701:1d00::3";
  mullvad_secret_file =
    if isServer then ../secrets/mullvad_wireguard.age else ../secrets/mullvad_wireguard_desktop.age;
in
{

  imports = [ inputs.vpn-confinement.nixosModules.default ];
}
// lib.mkMerge [
  {
    age.secrets.mullvad_wireguard.file = mullvad_secret_file;
    vpnNamespaces.${network_namespace} = {
      enable = true;
      wireguardConfigFile = config.age.secrets.mullvad_wireguard.path;
      namespaceAddress = namespace_address;
      namespaceAddressIPv6 = namespace_address_v6;
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
        Preferences.WebUI = {
          LocalHostAuth = false;
          # generate with the following command (make sure to prefix with a space to avoid going into shell history!)
          # nix run git+https://codeberg.org/feathecutie/qbittorrent_password -- -p [password here]
          Password_PBKDF2 = "@ByteArray(ayWHE7QQHrTEJ+yPm1ymsA==:uyzO//xbRfCTABjdHl9L74Dz4rXFAW60iHxp3GnFVUtwIWDVanKj+yRO3QWEfe54A+3SI/SuTmdEVwYfI1vE2A==)";
        };
        BitTorrent.Session = lib.mkMerge [
          {
            DefaultSavePath = "${data_dir}/media";
            TempPath = "${data_dir}/incomplete";
            TempPathEnabled = true;
            AnonymousModeEnabled = true;
            GlobalMaxSeedingMinutes = if isServer then -1 else 0;
          }
          (lib.optionalAttrs isServer {
            MaxActiveTorrents = -1;
            MaxActiveDownloads = 8;
            MaxActiveUploads = -1;
          })
        ];
      };
    };
    assertions = [
      {
        # do not let qbittorrent run if we aren't sure we've quarantined it to the network namespace
        # that is running behind the VPN
        assertion = config.systemd.services ? qbittorrent;
        message = "systemd service 'qbittorrent' not found - the qbittorrent service name may have changed";
      }
    ];
    systemd.services.qbittorrent.vpnConfinement = {
      enable = true;
      vpnNamespace = network_namespace;
    };
  }
  (lib.optionalAttrs isServer {
    services.nginx.subdomains.qbittorrent = {
      address = config.vpnNamespaces.${network_namespace}.namespaceAddress;
      port = qbittorrent_port;
    };
  })
  (lib.optionalAttrs (!isServer) {
    networking.hosts."${config.vpnNamespaces.${network_namespace}.namespaceAddress}" = [
      "qbittorrent.lan"
    ];
  })
]
