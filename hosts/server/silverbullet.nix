{ config, ... }:
let
  port = 9632;
in
{
  systemd.tmpfiles.rules = [ "d /var/lib/silverbullet 0770 root podman - -" ];
  age.secrets.silverbullet_env.file = ../../secrets/silverbullet_env.age;
  virtualisation.oci-containers.containers.silverbullet = {
    image = "ghcr.io/silverbulletmd/silverbullet:v2";
    autoStart = true;
    ports = [ "${toString  port}:${toString port}" ];
    volumes = [ "/var/lib/silverbullet:/space" ];
    environmentFiles = [ config.age.secrets.silverbullet_env.path ];
    environment = {
      SB_HOSTNAME = "0.0.0.0";
      SB_PORT = toString port;
      SB_INDEX_PAGE = "A: Home";
    };
  };

  # custom nginx virtual host to ensure PWA works offline
  services.nginx = {
    enable = true;
    virtualHosts."silverbullet.mjones.network" = {
      forceSSL = true;
      useACMEHost = "mjones.network";
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          proxyWebsockets = true;
          extraConfig = ''
            add_header Service-Worker-Allowed "/";
          '';
        };

        # Cache config otherwise offline does not work
        "/.config" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          extraConfig = ''
            add_header Cache-Control "public, max-age=86400, immutable";
            add_header Access-Control-Allow-Origin "*";
          '';
        };

        # Cache static assets
        "~ \\.(css|js|png|jpg|woff2|svg)$" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          extraConfig = ''
            add_header Cache-Control "public, max-age=604800";
          '';
        };

        # Cacheable service worker with update control
        "/service-worker.js" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          # This allows caching but checks for updates when online
          extraConfig = ''
            add_header Cache-Control "public, max-age=0";
            add_header Service-Worker-Allowed "/";
          '';
        };
      };
    };
  };
}
