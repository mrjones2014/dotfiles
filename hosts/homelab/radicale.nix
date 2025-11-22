{ config, ... }:
let
  port = 5232;
in
{
  age.secrets.radicale_htpasswd = {
    file = ../../secrets/radicale_htpasswd.age;
    owner = config.users.users.radicale.name;
    group = config.users.groups.radicale.name;
  };
  services.nginx.subdomains.radicale.port = port;
  services.radicale = {
    enable = true;
    settings = {
      server.hosts = [ "0.0.0.0:${toString port}" ];
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.age.secrets.radicale_htpasswd.path;
        htpasswd_encryption = "bcrypt";
      };
    };
  };
}
