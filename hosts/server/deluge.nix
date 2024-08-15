let configDir = "/var/lib/delugevpn";
in {
  opnix = {
    secrets.mullvad_wireguard_conf = {
      source = ''
        [Interface]
        # Device: Clever Ibex
        PrivateKey = {{ op://nixos-server/Mullvad VPN Private Key/Private Key }}
        Address = 10.64.35.106/32,fc00:bbbb:bbbb:bb01::1:2369/128
        DNS = 10.64.0.1
        PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
        PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT

        [Peer]
        PublicKey = IzqkjVCdJYC1AShILfzebchTlKCqVCt/SMEXolaS3Uc=
        AllowedIPs = 0.0.0.0/0,::0/0
        Endpoint = 143.244.47.65:51820
      '';
      path = "${configDir}/wireguard/mullvad_wireguard.conf";
    };
    systemdWantedBy = [ "podman-delugevpn" ];
  };

  systemd.tmpfiles.rules = [
    "d ${configDir} 055 delugevpn delugevpn - -"
    "d ${configDir}/wireguard 055 delugevpn delugevpn - -"
  ];
  networking.firewall = {
    allowedTCPPorts = [ 8112 8118 58846 58946 ];
    allowedUDPPorts = [ 8112 8118 58846 58946 ];
  };
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      delugevpn = {
        autoStart = true;
        image = "ghcr.io/binhex/arch-delugevpn";
        extraOptions =
          [ "--sysctl=net.ipv4.conf.all.src_valid_mark=1" "--privileged=true" ];
        ports = [ "8112:8112" "8118:8118" "58846:58846" "58946:58946" ];
        volumes = [ "/mnt/jellyfin:/data" "${configDir}:/config" ];
        environment = {
          VPN_ENABLED = "yes";
          VPN_PROV = "custom";
          VPN_CLIENT = "wireguard";
          STRICT_PORT_FORWARD = "yes";
          ENABLE_PRIVOXY = "yes";
          LAN_NETWORK = "192.168.189.0/24";
          NAME_SERVERS =
            "84.200.69.80,37.235.1.174,1.1.1.1,37.235.1.177,84.200.70.40,1.0.0.1";
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
