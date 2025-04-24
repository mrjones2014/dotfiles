{ config, pkgs, ... }:
let port = 8888; userGroup = "authelia"; in {
  users.groups.${userGroup} = { };
  users.users.${userGroup} = {
    group = userGroup;
    isSystemUser = true;
  };
  age.secrets = {
    authelia_enc_key = {
      file = ../../secrets/authelia_enc_key.age;
      owner = userGroup;
      group = userGroup;
    };
    authelia_jwt = {
      file = ../../secrets/authelia_jwt.age;
      owner = userGroup;
      group = userGroup;
    };
  };

  networking.firewall.allowedUDPPorts = [ port ];
  networking.firewall.allowedTCPPorts = [ port ];

  # CLI for management
  environment.systemPackages = [ pkgs.authelia ];

  services.nginx.virtualHosts."authelia.mjones.network" = {
    forceSSL = true;
    default = true;
    useACMEHost = "mjones.network";
    locations = {
      "/".proxyPass = "http://127.0.0.1:${toString port}";
      "/api/verify".proxyPass = "http://127.0.0.1:${toString port}";
      "/api/authz/".proxyPass = "http://127.0.0.1:${toString port}";
    };
  };
  services.authelia.instances.master = {
    enable = true;
    user = userGroup;
    group = userGroup;
    secrets = {
      storageEncryptionKeyFile = config.age.secrets.authelia_enc_key.path;
      jwtSecretFile = config.age.secrets.authelia_jwt.path;
    };
    settings = {
      theme = "dark";
      access_control.default_policy = "one_factor";
      authentication_backend.file.path = "/var/lib/authelia-master/users_database.yml";
      session.domain = "authelia.mjones.network";
      server.address = "tcp://:${toString port}/";
      storage.local.path = "/var/lib/authelia-master/db.sqlite3";
      notifier.filesystem.filename = "/var/lib/authelia-master/notifications.txt";
      # notifier.smtp = {}; # TODO setup emails
    };
  };
}
