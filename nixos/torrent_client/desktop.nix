{ isServer, ... }:
if (!isServer) then
  {
    age.secrets.mullvad_wireguard.file = ../../secrets/mullvad_wireguard_desktop.age;
    networking.firewall.interfaces."ve-qbittorrent-vpn".allowedTCPPorts = [ 8080 ];
  }
else
  { }
