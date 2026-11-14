# Secrets

Real secrets live in `secrets/*.age`. They are encrypted to:

- `secrets/master.pub` — the public half of a passphrase-protected age
  identity stored at `secrets/master.age`. Use this for editing from any
  machine.
- per-host SSH host keys — used by agenix during activation, so servers can
  decrypt unattended.

`agenix-rules.nix` is **not** imported by the NixOS/nix-darwin config. It is only
used by the `agenix` CLI to decide which recipients to encrypt to.

## One-time setup: create the master key

This must be done by you and the plaintext key must never be committed.
`age` and `agenix` are in the default dev shell, so run `direnv allow` (or
`nix develop`) in the repo first.

```bash
cd ~/git/dotfiles
umask 077

# Generate and immediately encrypt the private identity. Copy the public key
# printed by age-keygen into secrets/master.pub; never copy the private key.
age-keygen | age -p -a -o secrets/master.age
```

When `age -p` prompts, either enter a strong passphrase or press Enter to let
`age` generate one. Store the passphrase in 1Password. `secrets/master.age` is
safe to commit; `secrets/master.pub` is public.

Do **not** add `secrets/master.age` as a secret in `agenix-rules.nix` —
it is passphrase-only, not encrypted to recipients.

## Editing a secret

```bash
agenix-edit homarr_env
```

Run this from the repo (or a subdirectory) in the default dev shell. You can
also pass `secrets/homarr_env.age`. It prompts for the master passphrase; the
re-encrypted file uses the recipients in `agenix-rules.nix`, including the host
keys. The wrapper requires an interactive terminal to avoid accidentally
replacing a secret with piped input.

## Rekeying after changing recipients

`agenix` must decrypt a secret with an existing recipient before it can add a
new recipient. Changing `agenix-rules.nix` alone does not change existing files.
Commit and sync the rules and `secrets/master.pub` to `mikoshi`, then confirm
its `/etc/ssh/ssh_host_ed25519_key.pub` matches the server host key in the
rules. From the repo on `mikoshi`, with `agenix` available:

```bash
for f in secrets/cloudflare_certbot_token.age \
  secrets/gatus_discord_webhook_env.age \
  secrets/homarr_env.age \
  secrets/paperless_admin_pw.age \
  secrets/paperless_backups_1password_token_env.age \
  secrets/proton_wireguard_conf_server.age; do
  sudo env EDITOR=: "$(command -v agenix)" -e "$f" -i /etc/ssh/ssh_host_ed25519_key || break
  sudo chown "$(id -u):$(id -g)" "$f" || break
done
```

If any command fails, stop and investigate rather than assuming all files were
rekeyed. Sync the resulting ciphertext back through version control, then test
each file with `secrets/master.age`. The desktop secret is separate: its old
host or user private key is needed for its initial rekey. If neither remains,
recreate its WireGuard configuration from the provider. See recovery below.

## Verify the master key

```bash
agenix -d -i secrets/master.age secrets/homarr_env.age >/dev/null
```

`agenix -c` is not useful here because it only understands SSH recipient tags,
not native age recipients. Verify with `agenix -d` instead.

That should prompt for the passphrase and succeed. Verify every secret
individually; during migration the desktop file will fail until it has been
rekeyed or recreated:

```bash
for f in secrets/*.age; do
  [[ $f == secrets/master.age ]] && continue
  agenix -d -i secrets/master.age "$f" >/dev/null || echo "FAILED: $f"
done
```

## Removing the old user keys

`agenix-rules.nix` currently keeps `mat@homelab` and `mat@nixos-pc` as a
break-glass path. Once the master key works from every machine, remove those
entries and rekey again. The host keys stay: they are what lets each machine
decrypt without a human at boot.

## Recovery and rotation

- **Forgot the master passphrase:** generate a new master identity, add its
  public key to `agenix-rules.nix`, and rekey each secret using a private key that
  can already decrypt it. A server key cannot recover desktop-only secrets.
- **Reinstalled a host:** a newly generated host key cannot decrypt existing
  ciphertext. If the master can decrypt the secret, update the host public key
  in `agenix-rules.nix`, rekey the secret with the master, and deploy it before
  activation. Otherwise recover an old recipient private key or recreate the
  secret. Retaining the old host key also preserves access.
- **Rotating the master:** add the new public key alongside the old one,
  rekey with the old identity, remove the old public key, then rekey with the
  new one.
- **Revoking a key:** removing a recipient only affects future ciphertext.
  Old versions in git history remain decryptable with the old key. If a key
  was actually compromised, also rotate the secret values.
