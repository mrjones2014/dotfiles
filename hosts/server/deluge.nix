{ config, pkgs, ... }:
let
  configDir = "/var/delugevpn";
  wireguardConfigPath = config.age.secrets.mullvad_wireguard.path;
in {
  systemd.tmpfiles.rules = [
    "d ${configDir} 055 delugevpn delugevpn - -"
    "d ${configDir}/wireguard 055 delugevpn delugevpn - -"
  ];
  system.activationScripts.copyWireguardConfigIntoContainer.text = ''
    ${pkgs.podman}/bin/podman cp ${wireguardConfigPath} delugevpn:/config/wireguard/mullvad_wireguard.conf
  '';
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      delugevpn = {
        user = "delugevpn:delugevpn";
        image = "binhex/arch-delugevpn";
        extraOptions = [ "--cap-add=NET_ADMIN" ];
        ports = [ "8112:8112" "8118:8118" "58846:58846" "58946:58946" ];
        volumes = [ "/mnt/jellyfin:/data" "${configDir}:/config" ];
        environment = {
          VPN_ENABLED = "yes";
          VPN_PROV = "custom";
          VPN_CLIENT = "wireguard";
          STRICT_PORT_FORWARD = "yes";
          ENABLE_PRIVOXY = "yes";
          LAN_NETWORK = "192.168.1.0/24";
          NAME_SERVERS = "1.1.1.1";
          DELUGE_DAEMON_LOG_LEVEL = "info";
          DELUGE_WEB_LOG_LEVEL = "info";
          DELUGE_ENABLE_WEBUI_PASSWORD = "yes";
          VPN_INPUT_PORTS = "";
          VPN_OUTPUT_PORTS = "";
          DEBUG = "false";
          UMASK = "000";
          PUID = "0";
          PGID = "0";
        };
      };
    };
  };
}
