{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.proton-backup;
  inherit (lib)
    escapeShellArg
    mkIf
    mkOption
    types
    ;
  jobType = types.submodule (
    { name, ... }:
    {
      options = {
        user = mkOption { type = types.str; };
        group = mkOption { type = types.str; };
        stateDir = mkOption {
          type = types.str;
          default = "/var/lib/proton-backup/${name}";
          description = "Private persistent directory for credentials and backup staging.";
        };
        sourcePaths = mkOption {
          type = types.listOf types.str;
          description = "Runtime paths to upload; directories retain their basename in Proton Drive.";
        };
        remoteFolder = mkOption {
          type = types.str;
          description = "Folder name directly under Proton Drive's /my-files root.";
        };
        schedule = mkOption {
          type = types.str;
          description = "Systemd OnCalendar schedule for the backup.";
          example = "Sun 03:00:00";
        };
        discordEnvironmentFile = mkOption {
          type = types.str;
          description = "Systemd environment file containing DISCORD_WEBHOOK_URL.";
        };
        prepare = mkOption {
          type = types.lines;
          default = "";
          description = "Commands run as the backup user before checking and uploading sources.";
        };
        extraPackages = mkOption {
          type = types.listOf types.package;
          default = [ ];
        };
        timeout = mkOption {
          type = types.str;
          default = "2h";
        };
      };
    }
  );
  mkLogin =
    name: job:
    pkgs.callPackage ../../pkgs/proton-backup-login.nix {
      inherit name;
      inherit (job) user;
      home = job.stateDir;
      sudo = "${config.security.wrapperDir}/sudo";
    };
  mkJob =
    name: job:
    let
      service = "${name}-backup";
      remote = "/my-files/${job.remoteFolder}";
    in
    {
      name = service;
      value = {
        description = "Back up ${name} to Proton Drive";
        path =
          (with pkgs; [
            coreutils
            findutils
            proton-drive-cli
            gnupg
            pass
            util-linux
          ])
          ++ job.extraPackages;
        serviceConfig = {
          Type = "oneshot";
          User = job.user;
          Group = job.group;
          UMask = "0077";
          TimeoutStartSec = job.timeout;
        };
        onFailure = [ "${service}-notify.service" ];
        script = ''
          set -euo pipefail
          export HOME=${escapeShellArg job.stateDir}
          export GNUPGHOME="$HOME/gnupg"
          export PASSWORD_STORE_DIR="$HOME/password-store"
          export XDG_CACHE_HOME="$HOME/cache"
          export XDG_DATA_HOME="$HOME/data"
          export XDG_STATE_HOME="$HOME/state"
          export PROTON_DRIVE_CREDENTIALS_STORE=pass
          unset PROTON_DRIVE_CACHE_DIR

          exec 9>"$HOME/.lock"
          flock -n 9
          ${job.prepare}
          sources=(${lib.concatMapStringsSep " " escapeShellArg job.sourcePaths})
          for source in "''${sources[@]}"; do
            test -e "$source"
          done
          if ! proton-drive filesystem info ${escapeShellArg remote} --json >/dev/null 2>&1; then
            proton-drive filesystem create-folder /my-files ${escapeShellArg job.remoteFolder} --json
          fi
          proton-drive filesystem upload "''${sources[@]}" ${escapeShellArg remote} \
            --folder-conflict-strategy merge \
            --file-conflict-strategy create-new-revision --json
          echo ${escapeShellArg "${name} Proton Drive backup completed successfully."}
        '';
      };
    };
  mkNotify = name: job: {
    name = "${name}-backup-notify";
    value = {
      description = "Report ${name} backup failures to Discord";
      path = [ pkgs.curl ];
      serviceConfig = {
        Type = "oneshot";
        User = job.user;
        Group = job.group;
        EnvironmentFile = job.discordEnvironmentFile;
      };
      script = ''
        set -euo pipefail
        : "''${DISCORD_WEBHOOK_URL:?Discord webhook is not configured}"
        # Keep the webhook URL out of the process argument list.
        printf 'url = "%s"\n' "$DISCORD_WEBHOOK_URL" | curl --config - \
          --silent --show-error --fail --max-time 15 \
          --header 'Content-Type: application/json' \
          --data ${
            escapeShellArg (
              builtins.toJSON {
                content = "${name} backup failed on ${config.networking.hostName}. Check journalctl -u ${name}-backup.service. If Proton authentication expired, run ${name}-proton-login on ${config.networking.hostName}.";
              }
            )
          } \
          >/dev/null
      '';
    };
  };
in
{
  options.dotfiles.proton-backup.jobs = mkOption {
    type = types.attrsOf jobType;
    default = { };
    description = "Proton Drive backup jobs, each with a separate user and credential store.";
  };

  config = mkIf (cfg.jobs != { }) {
    assertions =
      (lib.mapAttrsToList (name: job: {
        assertion =
          builtins.match "[a-zA-Z0-9_-]+" name != null
          && builtins.match "[a-zA-Z0-9_-]+" job.remoteFolder != null
          && builtins.match "/[a-zA-Z0-9._/-]+" job.stateDir != null
          && job.sourcePaths != [ ]
          && lib.all (lib.hasPrefix "/") job.sourcePaths;
        message = "Proton backup ${name}: use simple names, an absolute state directory, and at least one absolute source path.";
      }) cfg.jobs)
      ++ [
        {
          assertion =
            lib.length (lib.unique (map (job: job.stateDir) (lib.attrValues cfg.jobs)))
            == lib.length (lib.attrValues cfg.jobs);
          message = "Each Proton backup job must use a separate state directory.";
        }
      ];
    environment.sessionVariables.PROTON_DRIVE_CREDENTIALS_STORE = "pass";
    environment.systemPackages = [
      pkgs.proton-drive-cli
      pkgs.pass
      pkgs.gnupg
    ]
    ++ lib.mapAttrsToList mkLogin cfg.jobs;
    systemd = {
      tmpfiles.rules = lib.mapAttrsToList (
        _: job: "d ${job.stateDir} 0700 ${job.user} ${job.group} - -"
      ) cfg.jobs;
      timers = lib.mapAttrs' (name: job: {
        name = "${name}-backup";
        value = {
          timerConfig = {
            Unit = "${name}-backup.service";
            OnCalendar = job.schedule;
          };
          wantedBy = [ "timers.target" ];
        };
      }) cfg.jobs;
      services = lib.mapAttrs' mkJob cfg.jobs // lib.mapAttrs' mkNotify cfg.jobs;
    };
  };
}
