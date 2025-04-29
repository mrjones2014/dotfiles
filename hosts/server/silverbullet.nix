{ config, ... }:
let
  port = 9632;
in
{
  systemd.tmpfiles.rules = [ "d /var/lib/silverbullet 0770 root podman - -" ];
  age.secrets.silverbullet_env.file = ../../secrets/silverbullet_env.age;
  services.nginx.subdomains.silverbullet.port = port;
  virtualisation.oci-containers.containers.silverbullet = {
    image = "ghcr.io/silverbulletmd/silverbullet:v2";
    autoStart = true;
    ports = [ "${toString  port}:${toString port}" ];
    volumes = [ "/var/lib/silverbullet:/space" ];
    environmentFiles = [ config.age.secrets.silverbullet_env.path ];
    environment = {
      SB_HOSTNAME = "0.0.0.0";
      SB_PORT = toString port;
    };
  };
}
