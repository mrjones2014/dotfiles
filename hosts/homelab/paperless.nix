{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.nginx.subdomains.paperless = {
    inherit (config.services.paperless) port;
    allowLargeUploads = true;
  };
  age.secrets = {
    paperless_admin_pw.file = ../../secrets/paperless_admin_pw.age;
    paperless_backups_1password_token_env.file = ../../secrets/paperless_backups_1password_token_env.age;
  };
  services.paperless = {
    enable = true;
    passwordFile = config.age.secrets.paperless_admin_pw.path;
    database.createLocally = true;
    settings.PAPERLESS_URL = "https://paperless.mjones.network";
    exporter.enable = true;
  };

  # once a week, upload backups to 1Password
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password-cli"
    ];
  systemd.timers.paperless-backup = {
    timerConfig = {
      Unit = "paperless-backup.service";
      OnCalendar = "Sun 03:00:00";
    };
    wantedBy = [ "timers.target" ];
  };
  systemd.services.paperless-backup = {
    description = "Automated backups of paperless-ngx into 1Password";
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = config.age.secrets.paperless_backups_1password_token_env.path;
      # prevents service from running every time I nixos-rebuild: https://wiki.nixos.org/wiki/Systemd/timers
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
    script = ''
      set -euo pipefail

      EXPORTS_DIR="${config.services.paperless.exporter.directory}"
      BACKUP_DIR="${config.services.paperless.dataDir}/backups"
      TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
      ARCHIVE_NAME="paperless-backup-$TIMESTAMP.zip"
      ARCHIVE_PATH="$BACKUP_DIR/$ARCHIVE_NAME"
      OP_VAULT_UUID="gbhys44duhnwqtsmekthv5b5m4"

      mkdir -p "$BACKUP_DIR"
      # go to parent dir
      pushd "$EXPORTS_DIR/.."
      ${pkgs.zip}/bin/zip -r "$ARCHIVE_PATH" "$(basename $EXPORTS_DIR)"
      popd

      # NOTE: workaround for `op` choking on lack of a config directory
      OP_CFG_DIR="/var/lib/op"
      mkdir -p "$OP_CFG_DIR"
      chmod 700 "$OP_CFG_DIR"
      if [ ! -f "$OP_CFG_DIR/config" ] || [ ! -s "$OP_CFG_DIR/config" ]; then
        echo "{}" > "$OP_CFG_DIR/config"
      fi
      chmod 600 $OP_CFG_DIR/config

      ${pkgs._1password-cli}/bin/op --config "$OP_CFG_DIR" document create "$ARCHIVE_PATH" --vault "$OP_VAULT_UUID" --title "$ARCHIVE_NAME"

      # if uploaded successfully, delete old backups
      find "$BACKUP_DIR" -type f -name "*.zip" -mtime +1 -delete
    '';
  };
}
