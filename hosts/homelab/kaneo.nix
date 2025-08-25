{
  config,
  pkgs,
  ...
}:
let
  backend_port = 1337;
  frontend_port = 5173;
  db_data_location = "/var/lib/kaneo/postgres-data";
  podman_network = "kaneo";
  podman_dns_port = 8054;
in
{
  systemd = {
    # Create required directories
    tmpfiles.rules = [
      "d ${db_data_location} 0755 root root - -"
    ];

    # Create network for containers
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

  # Load secrets from agenix encrypted file
  # Required secrets in kaneo_env.age:
  # - POSTGRES_PASSWORD: Secure password for PostgreSQL database
  # - JWT_ACCESS: Secure JWT token for backend authentication
  age.secrets.kaneo_env.file = ../../secrets/kaneo_env.age;
  
  # Configure nginx reverse proxy for external access
  services.nginx.subdomains.kaneo.port = frontend_port;
  
  # Set unique DNS port for podman network
  virtualisation.containers.containersConf.settings.network.dns_bind_port = podman_dns_port;
  
  virtualisation.oci-containers.containers = {
    # PostgreSQL database container
    kaneo-postgres = {
      autoStart = true;
      image = "postgres:16-alpine";
      volumes = [ "${db_data_location}:/var/lib/postgresql/data" ];
      networks = [ podman_network ];
      environmentFiles = [ config.age.secrets.kaneo_env.path ];
      environment = {
        POSTGRES_DB = "kaneo";
        POSTGRES_USER = "kaneo_user";
        # POSTGRES_PASSWORD is loaded from environmentFiles
      };
      extraOptions = [
        "--health-cmd=pg_isready -U kaneo_user -d kaneo"
        "--health-interval=10s"
        "--health-timeout=5s"
        "--health-retries=5"
      ];
    };

    # Kaneo API backend container
    kaneo-backend = {
      autoStart = true;
      image = "ghcr.io/usekaneo/api:latest";
      ports = [ "${toString backend_port}:${toString backend_port}" ];
      networks = [ podman_network ];
      environmentFiles = [ config.age.secrets.kaneo_env.path ];
      environment = {
        # Database connection will use password from environmentFiles
        DATABASE_URL = "postgresql://kaneo_user:\${POSTGRES_PASSWORD}@kaneo-postgres:5432/kaneo";
      };
      dependsOn = [ "kaneo-postgres" ];
      extraOptions = [
        "--health-cmd=curl -f http://localhost:${toString backend_port}/health || exit 1"
        "--health-interval=30s"
        "--health-timeout=10s"
        "--health-retries=3"
      ];
    };

    # Kaneo web frontend container
    kaneo-frontend = {
      autoStart = true;
      image = "ghcr.io/usekaneo/web:latest";
      ports = [ "${toString frontend_port}:${toString frontend_port}" ];
      networks = [ podman_network ];
      environment = {
        # Point frontend to backend via internal network
        KANEO_API_URL = "http://kaneo-backend:${toString backend_port}";
      };
      dependsOn = [ "kaneo-backend" ];
    };
  };
}