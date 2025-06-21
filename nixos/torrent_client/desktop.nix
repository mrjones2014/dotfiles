{ isServer, ... }:
if (!isServer) then
  {
    age.secrets.mullvad_wireguard.file = ../../secrets/mullvad_wireguard_desktop.age;
  }
else
  { }
