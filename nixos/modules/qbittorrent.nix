# verify that qbittorrent is running inside the network namespace with
#
# ps aux | grep qbittorrent # find the PID of qbittorrent
# sudo ip netns identify <PID> # it should output qbt-wg
#
# verify that the network namespace is behind the VPN with
# the following command and ensure 2 different IPs are printed.
#
# curl ip.me && sudo ip netns exec qbt-wg curl ip.me
{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.dotfiles.qbittorrent;
  network_namespace = "qbt-wg";
in
{
  imports = [ inputs.vpn-confinement.nixosModules.default ];

  options.dotfiles.qbittorrent = {
    enable = lib.mkEnableOption "qBittorrent confined to a VPN network namespace";
    dataDir = lib.mkOption {
      type = lib.types.str;
      description = "Directory downloads are saved under (media/ and incomplete/).";
    };
    namespaceAddress = lib.mkOption {
      type = lib.types.str;
      description = "IPv4 address of the VPN network namespace.";
    };
    namespaceAddressIPv6 = lib.mkOption {
      type = lib.types.str;
      description = "IPv6 address of the VPN network namespace.";
    };
    wireguardConfigFile = lib.mkOption {
      type = lib.types.path;
      description = "agenix-encrypted wireguard config for the VPN namespace.";
    };
    webuiPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "qBittorrent WebUI port.";
    };
    sessionSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Extra settings merged into BitTorrent.Session.";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.wireguard_conf.file = cfg.wireguardConfigFile;
    vpnNamespaces.${network_namespace} = {
      enable = true;
      wireguardConfigFile = config.age.secrets.wireguard_conf.path;
      inherit (cfg) namespaceAddress;
      inherit (cfg) namespaceAddressIPv6;
      accessibleFrom = [
        "192.168.1.0/24"
      ];
      portMappings = [
        {
          from = cfg.webuiPort;
          to = cfg.webuiPort;
          protocol = "tcp";
        }
      ];
    };
    services.qbittorrent = {
      enable = true;
      openFirewall = false;
      inherit (cfg) webuiPort;
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
            DefaultSavePath = "${cfg.dataDir}/media";
            TempPath = "${cfg.dataDir}/incomplete";
            TempPathEnabled = true;
            AnonymousModeEnabled = true;
          }
          cfg.sessionSettings
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
    systemd.services.qbittorrent = {
      vpnConfinement = {
        enable = true;
        vpnNamespace = network_namespace;
      };
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
