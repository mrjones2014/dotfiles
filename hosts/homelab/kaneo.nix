{
  config,
  pkgs,
  ...
}:
let
  backend_port = 8337;
  frontend_port = 8173;
  db_data_location = "/var/lib/kaneo/postgres-data";
  podman_network = "kaneo";
in
{
  systemd = {
    tmpfiles.rules = [ "d ${db_data_location} 0755 root root - -" ];

    services.kaneo-podman-network-create = {
      serviceConfig.Type = "oneshot";
      wantedBy = [
        "podman-kaneo-postgres.service"
        "podman-kaneo-backend.service"
        "podman-kaneo-frontend.service"
      ];
      script = ''
        ${pkgs.podman}/bin/podman network inspect ${podman_network} > /dev/null 2>&1 || ${pkgs.podman}/bin/podman network create ${podman_network}
      '';
    };
  };

  # Contains:
  # - POSTGRES_DB
  # - POSTGRES_USER
  # - POSTGRES_PASSWORD
  # - DATABASE_URL
  # - JWT_ACCESS
  age.secrets.kaneo_env.file = ../../secrets/kaneo_env.age;
  services.nginx.subdomains.kaneo.port = frontend_port;
  services.nginx.subdomains.kaneo-api.port = backend_port;
  virtualisation.oci-containers.containers = {
    kaneo-postgres = {
      autoStart = true;
      image = "postgres:16-alpine";
      volumes = [ "${db_data_location}:/var/lib/postgresql/data" ];
      networks = [ podman_network ];
      environmentFiles = [ config.age.secrets.kaneo_env.path ];
      extraOptions = [
        "--health-cmd=pg_isready -U kaneo_user -d kaneo"
        "--health-interval=10s"
        "--health-timeout=5s"
        "--health-retries=5"
      ];
    };

    kaneo-backend = {
      autoStart = true;
      image = "ghcr.io/usekaneo/api:latest";
      ports = [ "${toString backend_port}:1337" ];
      networks = [ podman_network ];
      environmentFiles = [ config.age.secrets.kaneo_env.path ];
      dependsOn = [ "kaneo-postgres" ];
    };

    kaneo-frontend = {
      autoStart = true;
      image = "ghcr.io/usekaneo/web:latest";
      ports = [ "${toString frontend_port}:5173" ];
      networks = [ podman_network ];
      environment.KANEO_API_URL = "https://kaneo-api.mjones.network";
      dependsOn = [ "kaneo-backend" ];
    };
  };
}
