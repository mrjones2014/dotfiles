{ config, ... }:
let
  port = 2021;
  dataDir = "/var/lib/donetick/data";
  configName = "selfhosted";
in
{
  age.secrets.donetick_config = {
    file = ../../secrets/donetick_config.age;
    name = configName;
  };
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 root root - -"
  ];
  services.nginx.subdomains.todo.port = port;
  virtualisation.oci-containers.containers.donetick = {
    autoStart = true;
    image = "donetick/donetick";
    ports = [ "${toString port}:2021" ];
    volumes = [
      "${dataDir}:/donetick-data"
      "${builtins.dirOf config.age.secrets.donetick_config.path}:/config"
    ];
    environment = {
      DT_ENV = configName;
      DT_SQLITE_PATH = "/donetick-data/donetick.db";
    };
  };
}
