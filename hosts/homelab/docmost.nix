{
  config,
  pkgs,
  ...
}:
let
  port = 3000;
  storage_location = "/var/lib/docmost/storage";
  db_data_location = "/var/lib/docmost/db-data";
  redis_data_location = "/var/lib/docmost/redis-data";
  podman_network = "docmost";
  podman_dns_port = 8053;
in
{
  systemd = {
    # Create required directories
    tmpfiles.rules = [
      "d ${storage_location} 0755 root root - -"
      "d ${db_data_location} 0755 root root - -"
      "d ${redis_data_location} 0755 root root - -"
    ];

    # Create network for containers
    services.docmost-podman-network-create = {
      serviceConfig.Type = "oneshot";
      wantedBy = [
        "podman-docmost-app.service"
        "podman-docmost-db.service"
        "podman-docmost-redis.service"
      ];
      script = ''
        ${pkgs.podman}/bin/podman network inspect ${podman_network} > /dev/null 2>&1 || ${pkgs.podman}/bin/podman network create ${podman_network}
      '';
    };
  };

  age.secrets.docmost_env.file = ../../secrets/docmost_env.age;
  services.nginx.subdomains.docs.port = port;
  virtualisation.containers.containersConf.settings.network.dns_bind_port = podman_dns_port;
  virtualisation.oci-containers.containers = {
    docmost-db = {
      autoStart = true;
      image = "postgres:16-alpine";
      volumes = [ "${db_data_location}:/var/lib/postgresql/data" ];
      networks = [ podman_network ];
      environmentFiles = [ config.age.secrets.docmost_env.path ];
      environment = {
        POSTGRES_DB = "docmost";
        POSTGRES_USER = "docmost";
      };
      extraOptions = [
        "--health-cmd=pg_isready -U docmost -d docmost"
        "--health-interval=10s"
        "--health-timeout=5s"
        "--health-retries=5"
      ];
    };

    docmost-redis = {
      autoStart = true;
      image = "redis:7.2-alpine";
      volumes = [ "${redis_data_location}:/data" ];
      networks = [ podman_network ];
      extraOptions = [
        "--health-cmd=redis-cli --raw incr ping"
        "--health-interval=10s"
        "--health-timeout=5s"
        "--health-retries=5"
      ];
    };

    docmost-app = {
      autoStart = true;
      image = "vito0912/forkmost:latest";
      volumes = [ "${storage_location}:/app/data/storage" ];
      ports = [ "${toString port}:${toString port}" ];
      networks = [ podman_network ];
      environmentFiles = [ config.age.secrets.docmost_env.path ];
      environment = {
        APP_URL = "http://localhost:${toString port}";
        REDIS_URL = "redis://docmost-redis:6379";
        DISABLE_TELEMETRY = "true";
      };
      dependsOn = [
        "docmost-db"
        "docmost-redis"
      ];
    };
  };
}
