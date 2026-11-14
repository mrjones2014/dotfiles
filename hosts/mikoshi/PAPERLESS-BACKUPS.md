# Paperless backups to Proton Drive

The `paperless-backup` service runs as `paperless` every Sunday at 03:00. It
archives the most recent Paperless export (normally produced daily at 01:30)
and uploads `/my-files/Paperless/paperless-backup.zip` to Proton Drive. A changed
archive becomes a new revision; Proton's plan-dependent version retention and
storage limits apply. The backup does not run a fresh export itself.
It refuses to start if the exporter is running or in a failed state, but it does
not lock the exporter for the duration of archiving. Avoid manually starting an
export while the backup is running.

## First login and recovery

After deploying the configuration, log in on `mikoshi` as your normal user:

```bash
paperless-proton-login
```

The command uses sudo to run as `paperless`. On first use it creates a dedicated
GPG key and `pass` store, then prints Proton's login URL; open that URL on another
device and complete sign-in. It reuses the store on subsequent logins. For
unattended backups the GPG key has **no passphrase**: anyone who gains access to
the `paperless` account can use the Proton session. The private key and session
stay under `/var/lib/paperless/proton-drive`, not in the repository or Nix store.

Interactive Proton commands run as your normal user use a different credential
store. To use the backup's session interactively, open a shell as `paperless`
and select the same paths:

```bash
sudo -u paperless -H bash
export HOME=/var/lib/paperless/proton-drive
export GNUPGHOME="$HOME/gnupg" PASSWORD_STORE_DIR="$HOME/password-store"
export XDG_CACHE_HOME="$HOME/cache" XDG_DATA_HOME="$HOME/data" XDG_STATE_HOME="$HOME/state"
export PROTON_DRIVE_CREDENTIALS_STORE=pass
unset PROTON_DRIVE_CACHE_DIR
proton-drive filesystem list /my-files/Paperless
exit
```

If the login or backup fails, check its journal. The helper will refuse to
reinitialize an incomplete password store; investigate it rather than deleting
it automatically. Losing the store or replacing the server requires a new login.

## Run and inspect

```bash
# Optional: generate a fresh export first. This temporarily stops Paperless;
# --wait ensures it finishes before the backup begins.
sudo systemctl start --wait paperless-exporter.service

# Upload the latest export now; the weekly timer remains enabled.
sudo systemctl start paperless-backup.service
journalctl -u paperless-backup.service -n 100 --no-pager
systemctl list-timers paperless-backup.timer
```

Systemd sends failures to the existing Discord webhook and suggests running
`paperless-proton-login` if authentication has expired. Check
`journalctl -u paperless-backup-notify.service` if notification delivery fails.
If the webhook secret itself cannot be loaded or Discord is unreachable, the
notification cannot be delivered; the failed unit remains visible in systemd.

The previous local 1Password ZIPs and encrypted 1Password token have not been
deleted. Keep the 1Password backups until a Proton upload **and restore** have
been verified. The token is no longer used by the configuration; a future
`agenix rekey -a` may remove its generated host copy as an orphan.

## Test a restore

Periodically download the archive from Proton Drive to a safe location and test
the Paperless document importer in a separate instance. Do not overwrite the live
instance when testing. The local ZIP under the `paperless` user's Proton home is
plaintext; protect any downloaded copy in the same way.
