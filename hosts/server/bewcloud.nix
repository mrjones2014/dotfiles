{ config, ... }:
let
  # TODO rename the nextcloud directory, it used to be for nextcloud
  data_home = "/mnt/nextcloud/data-files";
  db_home = "/mnt/nextcloud/db";
  bewcloud_port = 8000;
  db_port = 5432;
  db_container_name = "bewcloud_postgresql";
in {
  age.secrets.bewcloud_env.file = ../../secrets/bewcloud_env.age;
  networking.firewall = {
    allowedTCPPorts = [ bewcloud_port ];
    allowedUDPPorts = [ bewcloud_port ];
  };
  systemd.tmpfiles.rules =
    [ "d ${data_home} 777 root root -" "d ${db_home} 777 root root -" ];
  virtualisation.oci-containers.containers = {
    bewcloud = {
      autoStart = true;
      image = "ghcr.io/bewcloud/bewcloud:main";
      ports = [
        "${builtins.toString bewcloud_port}:${builtins.toString bewcloud_port}"
      ];
      volumes = [ "${data_home}:/app/data-files" ];
      environmentFiles = [ config.age.secrets.bewcloud_env.path ];
      environment = {
        PORT = builtins.toString bewcloud_port;
        BASE_URL =
          "http://${import ./ip.nix}:${builtins.toString bewcloud_port}";
        POSTGRESQL_HOST = "host.containers.internal";
        POSTGRESQL_PORT = builtins.toString db_port;
        CONFIG_ALLOW_SIGNUPS = "false";
        CONFIG_ENABLED_APPS = "news,notes,photos,expenses";
        CONFIG_FILES_ROOT_PATH = "data-files";
        CONFIG_ENABLE_EMAILS = "false";
        CONFIG_ENABLE_FOREVER_SIGNUP = "true";
      };
    };

    ${db_container_name} = {
      autoStart = true;
      image = "postgres:15";
      ports = [ "${builtins.toString db_port}:${builtins.toString db_port}" ];
      volumes = [ "${db_home}:/var/lib/postgresql/data" ];
      environmentFiles = [ config.age.secrets.bewcloud_env.path ];
    };
  };

}

