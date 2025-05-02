{ config, pkgs, ... }:
let
  db_name_user = "joplin";
  app_port = 9229;
  db_port = 9339;
  db_data = "/var/lib/joplin-db";
  app_data = "/var/lib/joplin";
  podman_network = "joplin";
  podman_dns_port = 8053;
in
{
  systemd.tmpfiles.rules = [
    "d ${db_data} 0770 root podman - -"
    "d ${app_data} 0770 root podman - -"
  ];
  age.secrets.joplin_env.file = ../../secrets/joplin_env.age;
  services.nginx.subdomains.joplin.port = app_port;
  systemd.services.joplin-podman-network-create = {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "podman-joplin-server.service" "podman-joplin-db.service" ];
    script = ''
      ${pkgs.podman}/bin/podman network inspect ${podman_network} > /dev/null 2>&1 || ${pkgs.podman}/bin/podman network create ${podman_network}
    '';
  };
  virtualisation.containers.containersConf.settings.network.dns_bind_port = podman_dns_port;
  # the postres password and MAILER_* config variables are in the encrypted environment file
  virtualisation.oci-containers.containers = {
    joplin-db = {
      autoStart = true;
      image = "postgres:15";
      volumes = [ "${db_data}:/var/lib/postgresql/data" ];
      ports = [ "${toString db_port}:${toString db_port}" ];
      networks = [ podman_network ];
      environmentFiles = [ config.age.secrets.joplin_env.path ];
      environment = {
        POSTGRES_DB = db_name_user;
        POSTGRES_USER = db_name_user;
      };
    };
    joplin-server = {
      autoStart = true;
      image = "joplin/server:latest";
      ports = [ "${toString app_port}:${toString app_port}" ];
      networks = [ podman_network ];
      environmentFiles = [ config.age.secrets.joplin_env.path ];
      environment = {
        APP_PORT = toString app_port;
        APP_BASE_URL = "https://joplin.mjones.network";
        DB_CLIENT = "pg";
        POSTGRES_DATABASE = db_name_user;
        POSTGRES_USER = db_name_user;
        POSTGRES_PORT = toString config.services.postgresql.settings.port;
        POSTGRES_HOST = "joplin-db";
        SIGNUP_ENABLED = "1";
      };
    };
  };
}
