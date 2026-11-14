{ config, pkgs, ... }:
let
  protonHome = "${config.services.paperless.dataDir}/proton-drive";
  protonLogin = pkgs.callPackage ../../pkgs/paperless-proton-login.nix {
    user = config.services.paperless.user;
    home = protonHome;
    sudo = "${config.security.wrapperDir}/sudo";
  };
in
{
  dotfiles.nginx.subdomains.paperless = {
    inherit (config.services.paperless) port;
    allowLargeUploads = true;
  };
  age.secrets = {
    paperless_admin_pw = {
      rekeyFile = ../../secrets/paperless_admin_pw.age;
      owner = config.services.paperless.user;
    };
  };
  services.paperless = {
    enable = true;
    passwordFile = config.age.secrets.paperless_admin_pw.path;
    database.createLocally = true;
    domain = "paperless.mjones.network";
    exporter.enable = true;
  };

  environment.sessionVariables.PROTON_DRIVE_CREDENTIALS_STORE = "pass";
  environment.systemPackages = [
    pkgs.proton-drive-cli
    pkgs.pass
    pkgs.gnupg
    protonLogin
  ];

  systemd = {
    tmpfiles.rules = [
      "d ${protonHome} 0700 ${config.services.paperless.user} ${config.services.paperless.group} - -"
    ];

    # Once a week, upload the most recent Paperless export to Proton Drive.
    timers.paperless-backup = {
      timerConfig = {
        Unit = "paperless-backup.service";
        OnCalendar = "Sun 03:00:00";
      };
      wantedBy = [ "timers.target" ];
    };
    services = {
      paperless-backup = {
        description = "Back up the latest Paperless export to Proton Drive";
        path = with pkgs; [
          coreutils
          proton-drive-cli
          zip
          gnupg
          pass
          util-linux
        ];
        serviceConfig = {
          Type = "oneshot";
          User = config.services.paperless.user;
          Group = config.services.paperless.group;
          UMask = "0077";
          TimeoutStartSec = "2h";
        };
        onFailure = [ "paperless-backup-notify.service" ];
        script = ''
          set -euo pipefail
          export HOME=${protonHome}
          export GNUPGHOME="$HOME/gnupg"
          export PASSWORD_STORE_DIR="$HOME/password-store"
          export XDG_CACHE_HOME="$HOME/cache"
          export XDG_DATA_HOME="$HOME/data"
          export XDG_STATE_HOME="$HOME/state"
          export PROTON_DRIVE_CREDENTIALS_STORE=pass
          unset PROTON_DRIVE_CACHE_DIR

          exec 9>"$HOME/.lock"
          flock -n 9
          exporter_state="$(systemctl show --property=ActiveState --value paperless-exporter.service)"
          if [[ "$exporter_state" != inactive ]]; then
            echo "Paperless exporter is $exporter_state; refusing to archive its output." >&2
            exit 1
          fi
          EXPORTS_DIR="${config.services.paperless.exporter.directory}"
          BACKUP_DIR="$HOME/backups"
          mkdir -p "$BACKUP_DIR/Paperless"
          test -s "$EXPORTS_DIR/manifest.json"
          temporary_dir="$(mktemp -d "$BACKUP_DIR/.archive.XXXXXXXX")"
          trap 'rm -rf -- "$temporary_dir"' EXIT
          (cd "$(dirname "$EXPORTS_DIR")" && zip -qr "$temporary_dir/paperless-backup.zip" "$(basename "$EXPORTS_DIR")")
          mv -f "$temporary_dir/paperless-backup.zip" "$BACKUP_DIR/Paperless/paperless-backup.zip"

          proton-drive filesystem upload "$BACKUP_DIR/Paperless" /my-files \
            --folder-conflict-strategy merge \
            --file-conflict-strategy create-new-revision --json
          echo "Paperless Proton Drive backup completed successfully."
        '';
      };
      paperless-backup-notify = {
        description = "Report Paperless backup failures to Discord";
        path = [ pkgs.curl ];
        serviceConfig = {
          Type = "oneshot";
          User = config.services.paperless.user;
          Group = config.services.paperless.group;
          EnvironmentFile = config.age.secrets.discord_webhook_env.path;
        };
        script = ''
          set -euo pipefail
          : "''${DISCORD_WEBHOOK_URL:?Discord webhook is not configured}"
          # Keep the webhook URL out of the process argument list.
          printf 'url = "%s"\n' "$DISCORD_WEBHOOK_URL" | curl --config - \
            --silent --show-error --fail --max-time 15 \
            --header 'Content-Type: application/json' \
            --data '{"content":"Paperless backup failed on mikoshi. Check journalctl -u paperless-backup.service. If Proton authentication expired, run paperless-proton-login on mikoshi."}' \
            >/dev/null
        '';
      };
    };
  };
}
