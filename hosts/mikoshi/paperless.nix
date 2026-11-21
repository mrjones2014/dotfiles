{ config, ... }:
{
  dotfiles.nginx.subdomains.paperless = {
    inherit (config.services.paperless) port;
    allowLargeUploads = true;
  };
  age.secrets.paperless_admin_pw = {
    rekeyFile = ../../secrets/paperless_admin_pw.age;
    owner = config.services.paperless.user;
  };
  services.paperless = {
    enable = true;
    passwordFile = config.age.secrets.paperless_admin_pw.path;
    database.createLocally = true;
    domain = "paperless.mjones.network";
    exporter = {
      enable = true;
      onCalendar = "00:30:00";
    };
  };

  dotfiles.proton-backup.jobs.paperless = {
    user = config.services.paperless.user;
    group = config.services.paperless.group;
    sourcePaths = [ config.services.paperless.exporter.directory ];
    remoteFolder = "Paperless";
    schedule = "*-*-* 02:00:00";
    discordEnvironmentFile = config.age.secrets.discord_webhook_env.path;
    prepare = ''
      exporter_state="$(systemctl show --property=ActiveState --value paperless-exporter.service)"
      if [[ "$exporter_state" != inactive ]]; then
        echo "Paperless exporter is $exporter_state; refusing to upload its output." >&2
        exit 1
      fi
      test -s ${config.services.paperless.exporter.directory}/manifest.json
    '';
  };
}
