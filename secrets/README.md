# Secrets

Secrets in `secrets/*.age` are managed by agenix-rekey. The master identity is
`secrets/master.age`, encrypted with a passphrase; its public key is in
`secrets/master.pub`. Keep the passphrase outside the repository. Never put an
unencrypted private key in the repo or the Nix store.

The NixOS `age.secrets.<name>.rekeyFile` declarations determine which secrets
each host needs. Each host's `age.rekey.hostPubkey` is configured in
`hosts/<hostname>/default.nix`. The `local` storage mode stores host-encrypted
copies in `secrets/rekeyed/<hostname>/`, so those files can be committed and CI
can build without the master passphrase. Only generated files should go in
those directories: agenix-rekey removes files it considers orphaned.

## Initial migration

The existing master identity and encrypted secrets are reused. From the repo
root in `nix develop` (or after `direnv allow`):

```bash
agenix rekey -a
```

Enter the master passphrase when prompted. This creates the host-encrypted
files and adds them to Git; inspect the changes and commit them along with the
Nix configuration. Do not deploy the migration until all required files have
been generated successfully. If an existing secret cannot be decrypted, abort
rather than selecting a dummy value. See recovery below.

The existing source secrets may still include the old SSH recipients; migrating
the Nix config does not remove those recipients or change old ciphertext in Git
history.

## Editing and deploying

From the repo root, enter the default dev shell and edit a secret:

```bash
agenix edit secrets/homarr_env.age
# Or use the convenience wrapper from the repo or a subdirectory:
agenix-edit homarr_env
```

Then generate the affected host-encrypted files:

```bash
agenix rekey -a
```

The command may prompt for the passphrase once per changed secret and host.
Commit the source and generated encrypted files, push, pull on the target, and
run `nh os switch`. Normal rebuilds don't need rekeying if the encrypted inputs
and host public key haven't changed.

The editor sees plaintext. Disable editor swap, backup, undo history, and other
plugins or integrations that might persist or upload secrets. The
agenix-rekey editor command also disables unsafe options for Vim and Neovim.

## Installing or reinstalling a host

Generate or preserve the host's SSH key on the target, and set
`age.rekey.hostPubkey` to its **public** key in the corresponding host's
`default.nix`. Run `agenix rekey -a` from the repo root on a machine with the
master passphrase, commit the updated host-encrypted files, and deploy. The
host decrypts its copy using its private SSH host key; it does not need the
master passphrase for activation.

If the host public key is initially unknown, agenix-rekey supports a dummy key
for bootstrapping, but secrets will not decrypt until the actual public key is
configured and the files are rekeyed and deployed again.

For `edgerunner`, qBittorrent is temporarily disabled because its old
WireGuard secret could not be decrypted. On reinstall, create a new Proton
WireGuard config and encrypt it with
`agenix edit secrets/proton_wireguard_conf_desktop.age`, update the host public
key, and restore the qBittorrent settings in `hosts/edgerunner/default.nix`
before rekeying. Keep the plaintext config out of the repo and Nix store.

## Recovery and rotation

- **Master passphrase lost:** any old recipient private keys may still decrypt
  source files that were encrypted to them. Otherwise recover from another
  backup or recreate the secret. Host-encrypted copies in
  `secrets/rekeyed/<hostname>/` can also be decrypted using that host's key.
- **Host key replaced:** update the host public key, then run `agenix rekey -a`
  and deploy the resulting files before relying on secret activation.
- **Revoking a key:** removing a recipient only affects future ciphertext.
  Old versions in Git history remain decryptable with the old key. If a key
  was compromised, rotate the secret values as well.
