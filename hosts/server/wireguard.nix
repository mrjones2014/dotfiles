{ pkgs, config, ... }:
let
  wireguard_port = 9999;
  wireguard_interface = "wgvpn";
  external_interface = "enp0s31f6";
in {
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  services.dnsmasq = {
    enable = true;
    settings = { interface = wireguard_interface; };
  };
  networking = {
    # Enable NAT
    nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = external_interface;
      internalInterfaces = [ wireguard_interface ];
    };
    # Open ports in the firewall
    firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 wireguard_port ];
    };
    wg-quick.interfaces = {
      # the network interface name. You can name the interface arbitrarily.
      "${wireguard_interface}" = {
        # Determines the IP/IPv6 address and subnet of the client's end of the tunnel interface
        address = [ "10.0.0.1/24" "fdc9:281f:04d7:9ee9::1/64" ];
        # The port that WireGuard listens to - recommended that this be changed from default
        listenPort = wireguard_port;
        # Path to the server's private key
        privateKeyFile = config.age.secrets.wireguard_server.path;

        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        postUp = ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i ${wireguard_interface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.1/24 -o ${external_interface} -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -A FORWARD -i ${wireguard_interface} -j ACCEPT
          ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o ${external_interface} -j MASQUERADE
        '';

        # Undo the above
        preDown = ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -i ${wireguard_interface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.1/24 -o ${external_interface} -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -D FORWARD -i ${wireguard_interface} -j ACCEPT
          ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s fdc9:281f:04d7:9ee9::1/64 -o ${external_interface} -j MASQUERADE
        '';

        peers = [{
          publicKey = "klCZN17QW/0ZtAlmj24R6ftBRozXUGn3hvWjF9ledC4=";
          allowedIPs = [ "10.0.0.2/28" "fdc9:281f:04d7:9ee9::2/64" ];
        }];
      };
    };
  };
}
