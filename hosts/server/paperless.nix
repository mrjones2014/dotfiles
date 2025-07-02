{ config, ... }:
{
  services.nginx.subdomains.paperless = {
    inherit (config.services.paperless) port;
    allowLargeUploads = true;
  };
  age.secrets.paperless_admin_pw.file = ../../secrets/paperless_admin_pw.age;
  services.paperless = {
    enable = true;
    passwordFile = config.age.secrets.paperless_admin_pw.path;
    database.createLocally = true;
    settings.PAPERLESS_URL = "https://paperless.mjones.network";
  };
}
