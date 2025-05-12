{ pkgs, config, ... }:
let
  wireguard_port = 9999;
  wireguard_interface = "wgvpn";
  external_interface = "enp0s31f6";
in
{
  age.secrets.wireguard_server.file = ../../secrets/wireguard_server.age;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking = {
    # Enable NAT
    nat = {
      enable = true;
      externalInterface = external_interface;
      internalInterfaces = [ wireguard_interface ];
    };
    firewall.allowedUDPPorts = [ wireguard_port ];
    wg-quick.interfaces = {
      # the network interface name. You can name the interface arbitrarily.
      "${wireguard_interface}" = {
        # Determines the IP address and subnet of the client's end of the tunnel interface
        address = [ "10.0.0.1/24" ];
        # The port that WireGuard listens to - recommended that this be changed from default
        listenPort = wireguard_port;
        # Path to the server's private key
        privateKeyFile = config.age.secrets.wireguard_server.path;

        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        postUp = ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i ${wireguard_interface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.1/24 -o ${external_interface} -j MASQUERADE
          # Force all DNS traffic through local AdGuard Home
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ${wireguard_interface} -p udp --dport 53 -j DNAT --to-destination 10.0.0.1:53
          ${pkgs.iptables}/bin/iptables -t nat -A PREROUTING -i ${wireguard_interface} -p tcp --dport 53 -j DNAT --to-destination 10.0.0.1:53
        '';

        # Undo the above
        preDown = ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -i ${wireguard_interface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.1/24 -o ${external_interface} -j MASQUERADE

          # Remove DNS redirection rules
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ${wireguard_interface} -p udp --dport 53 -j DNAT --to-destination 10.0.0.1:53
          ${pkgs.iptables}/bin/iptables -t nat -D PREROUTING -i ${wireguard_interface} -p tcp --dport 53 -j DNAT --to-destination 10.0.0.1:53
        '';

        peers = [
          {
            publicKey = "klCZN17QW/0ZtAlmj24R6ftBRozXUGn3hvWjF9ledC4=";
            allowedIPs = [ "10.0.0.2/32" ];
          }
          # Robby/Megan
          {
            publicKey = "0XXP3UgA67bcImCB4UOvyno3fhiBx7v6ufd4y4MH1xE=";
            allowedIPs = [ "10.0.0.3/32" ];
          }
          # Andrew
          {
            publicKey = "30hYSNSsFVjTmi4553kdbucg5laEkGvERgHxgqnDGkE=";
            allowedIPs = [ "10.0.0.4/32" ];
          }
        ];
      };
    };
  };
}
