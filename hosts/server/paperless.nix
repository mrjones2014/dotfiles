{ config, ... }:
{
  services.nginx.subdomains.paperless.port = config.services.paperless.port;
  age.secrets.paperless_admin_pw.file = ../../secrets/paperless_admin_pw.age;
  services.paperless = {
    # FIXME: paperless-ngx currently dumps core and spam-restarts itself pinning CPU usage to 100%
    # https://github.com/NixOS/nixpkgs/issues/414214
    # https://github.com/NixOS/nixpkgs/pull/414234
    # https://nixpk.gs/pr-tracker.html?pr=414234
    enable = false;
    passwordFile = config.age.secrets.paperless_admin_pw.path;
    database.createLocally = true;
    settings.PAPERLESS_URL = "https://paperless.mjones.network";
  };
}
