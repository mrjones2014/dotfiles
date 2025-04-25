{ config, ... }:
let
  port = 8888;
in
{
  age.secrets.keycloak_db_pw.file = ../../secrets/keycloak_db_pw.age;
  services.keycloak = {
    enable = true;
    # change this password immediately after logging in
    initialAdminPassword = "changeme";
    database = {
      createLocally = true;
      passwordFile = config.age.secrets.keycloak_db_pw.path;
    };
    settings = {
      http-port = port;
      http-host = "127.0.0.1";
      http-enabled = true;
      hostname = "keycloak.mjones.network";
      proxy-headers = "xforwarded";
    };
  };

  services.nginx.virtualHosts."keycloak.mjones.network" = {
    forceSSL = true;
    default = true;
    useACMEHost = "mjones.network";
    extraConfig = ''
      add_header Content-Security-Policy "frame-src 'self' https://keycloak.mjones.network;";
      add_header X-Forwarded-For "$proxy_add_x_forwarded_for";
      add_header X-Forwarded-Proto "$scheme";
    '';
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
      };
    };
  };
}
