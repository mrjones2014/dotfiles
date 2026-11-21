# Proton Drive backups

`dotfiles.proton-backup.jobs` defines independent scheduled uploads. Each job
runs as its configured user, has a private state directory and Proton session,
and creates a `<name>-backup.service`, timer, failure notification, and
`<name>-proton-login` command. For example:

```nix
dotfiles.proton-backup.jobs.example = {
  user = "example";
  group = "example";
  sourcePaths = [ "/var/lib/example/export" ];
  remoteFolder = "Example"; # under /my-files
  schedule = "Sun 03:00:00"; # systemd OnCalendar expression
  discordEnvironmentFile = config.age.secrets.discord_webhook_env.path;
  # Optional: prepare sources before upload and add commands to the service PATH.
  # prepare = ''...'';
  # extraPackages = [ pkgs.example ];
};
```

The source paths must be accessible to the job's user. `prepare` runs under
that user before the upload and can be used to create or validate them. The
default private state directory is `/var/lib/proton-backup/<name>`; it can be
overridden with `stateDir`. Set `timeout` to override the default `2h` limit.
Job and remote folder names may contain letters, numbers, `_` and `-`.

Run `<name>-proton-login` on the server after deployment. It initializes a
dedicated GPG key and `pass` store if needed, then opens a Proton login flow.
The GPG key has **no passphrase** so scheduled jobs can use it unattended;
anyone with access to that service account can use its Proton session. The
state directory holds private credentials and may also contain plaintext
staged backups. Keep it outside the Nix store and the source being backed up.
Different jobs do not share Proton sessions, even when they use the same Proton
account. Paperless now uses the default state directory; run
`paperless-proton-login` after deploying to sign in again. Its old
`/var/lib/paperless/proton-drive` directory is not removed automatically.

The CLI merges directories and creates revisions for changed files; it does not
remove remote files deleted locally. Proton's plan-dependent revision retention
and storage limits apply. An interrupted multi-file upload can leave a mixture
of old and new files, not a point-in-time snapshot. Failures are reported via
Discord when the webhook is available; inspect `journalctl -u <name>-backup`
and `journalctl -u <name>-backup-notify` for details.

## Paperless on mikoshi

The Paperless job uploads the latest existing export to
`/my-files/Paperless/export` every day at 02:00. It does not create an export;
the Paperless exporter normally runs daily at 00:30. If the export is still
running at 02:00, the upload fails and sends an alert. To generate a fresh
export and then upload it on demand:

```bash
# This temporarily stops Paperless while the export runs.
sudo systemctl start --wait paperless-exporter.service
sudo systemctl start paperless-backup.service
```

Do not start the exporter during an upload. Old 1Password backups and the older
Proton ZIP are not deleted by this job. Keep them until a restore of the new
backup has been tested.

## Home Assistant on mikoshi

1. In Home Assistant, open **Settings → System → Backups** and enable automatic
   backups with **local storage**. Choose a daily time that completes well
   before Sunday 02:00, for example 00:30, and keep at least one local backup.
2. Download and securely store Home Assistant's backup emergency kit. The
   encryption key is needed to restore encrypted HA backups.
3. After deploying, run `home-assistant-proton-login` on mikoshi and complete
   the Proton sign-in. This is separate from the Paperless login.

Every Sunday at 02:00, the job uploads Home Assistant's local `backups`
directory directly to `/my-files/HomeAssistant/backups`. It requires a nonempty
`.tar` modified more than 10 minutes and less than 72 hours ago, and refuses to
run if any `.tar` was modified in the last 10 minutes. These age checks do not
prove a backup completed successfully or prevent a new backup from starting
during upload; check Home Assistant's backup status too. Failures send a
Discord notification.

This is a merge: files removed by Home Assistant's local retention remain in
Proton Drive, so offsite storage usage can grow indefinitely. No local or remote
backups are deleted by this job.

The separate PostgreSQL `hass` database is **not** backed up, so recorder
history and long-term statistics will be lost on restore. External Z-Wave JS
state and other services are also excluded.

```bash
sudo systemctl start home-assistant-backup.service
journalctl -u home-assistant-backup.service -n 100 --no-pager
systemctl list-timers home-assistant-backup.timer
```

For recovery, download the HA archive and restore it in a separate test
instance with the emergency-kit key. Verify the result before relying on the
backup; do not overwrite the live system during a test.
