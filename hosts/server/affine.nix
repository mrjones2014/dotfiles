{
  config,
  pkgs,
  lib,
  ...
}:
let
  port = 3010;
  upload_location = "/var/lib/affine/storage";
  config_location = "/var/lib/affine/config";
  db_data_location = "/var/lib/affine/db-data";
  affine_version = "stable";
  podman_network = "affine";
  podman_dns_port = 8053;
in
{
  systemd = {
    # Create required directories
    tmpfiles.rules = [
      "d ${upload_location} 0777 root podman - -"
      "d ${config_location} 0777 root podman - -"
      "d ${db_data_location} 0777 root podman - -"
    ];

    # Create network for containers
    services.affine-podman-network-create = {
      serviceConfig.Type = "oneshot";
      wantedBy = [
        "podman-affine-server.service"
        "podman-affine-migration.service"
        "podman-affine-redis.service"
        "podman-affine-postgres.service"
      ];
      script = ''
        ${pkgs.podman}/bin/podman network inspect ${podman_network} > /dev/null 2>&1 || ${pkgs.podman}/bin/podman network create ${podman_network}
      '';
    };

    # Modify the systemd service for migration to run once and not restart
    services.podman-affine-migration = {
      serviceConfig = {
        # Run once and don't restart
        Type = lib.mkForce "oneshot";
        Restart = lib.mkForce "on-failure";
        RemainAfterExit = true;
      };
    };
  };

  age.secrets.affine_env.file = ../../secrets/affine_env.age;
  services.nginx.subdomains.affine.port = port;
  virtualisation.containers.containersConf.settings.network.dns_bind_port = podman_dns_port;
  virtualisation.oci-containers.containers = {
    affine-postgres = {
      autoStart = true;
      image = "postgres:16";
      volumes = [ "${db_data_location}:/var/lib/postgresql/data" ];
      networks = [ podman_network ];
      environmentFiles = [ config.age.secrets.affine_env.path ];
      environment.POSTGRES_INITDB_ARGS = "--data-checksums";
      cmd = [ ];
      extraOptions = [
        "--health-cmd=pg_isready -U $DB_USERNAME -d $DB_NAME"
        "--health-interval=10s"
        "--health-timeout=5s"
        "--health-retries=5"
      ];
    };

    affine-redis = {
      autoStart = true;
      image = "redis";
      networks = [ podman_network ];
      cmd = [ ];
      extraOptions = [
        "--health-cmd=redis-cli --raw incr ping"
        "--health-interval=10s"
        "--health-timeout=5s"
        "--health-retries=5"
      ];
    };

    affine-migration = {
      autoStart = false;
      image = "ghcr.io/toeverything/affine-graphql:${affine_version}";
      volumes = [
        "${upload_location}:/root/.affine/storage"
        "${config_location}:/root/.affine/config"
      ];
      networks = [ podman_network ];
      environmentFiles = [ config.age.secrets.affine_env.path ];
      environment = {
        REDIS_SERVER_HOST = "affine-redis";
        DB_PASSWORD = "$POSTGRES_PASSWORD"; # Ensure DB_PASSWORD is set
      };
      cmd = [
        "sh"
        "-c"
        "NODE_ENV=production node ./scripts/self-host-predeploy.js; exit_code=$?; echo \"Migration completed with status $exit_code\"; exit $exit_code"
      ];
      dependsOn = [
        "affine-postgres"
        "affine-redis"
      ];
      extraOptions = [
        "--log-driver=journald"
      ];
    };

    affine-server = {
      autoStart = true;
      image = "ghcr.io/toeverything/affine-graphql:${affine_version}";
      volumes = [
        "${upload_location}:/root/.affine/storage"
        "${config_location}:/root/.affine/config"
      ];
      ports = [ "${toString port}:${toString port}" ];
      networks = [ podman_network ];
      environmentFiles = [ config.age.secrets.affine_env.path ];
      environment = {
        REDIS_SERVER_HOST = "affine-redis";
        DB_PASSWORD = "$POSTGRES_PASSWORD"; # Ensure DB_PASSWORD is set
      };
      dependsOn = [
        "affine-postgres"
        "affine-redis"
        "affine-migration"
      ];
    };
  };
}
