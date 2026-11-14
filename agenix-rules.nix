# This rules file is NOT imported into the NixOS config,
# it is only used by the agenix CLI to determine which
# keys to use to encrypt secrets.
let
  # Public key for the passphrase-protected master identity stored in
  # secrets/master.age. This is the key you use when editing secrets from
  # any machine; the passphrase is the only thing you need to remember.
  master =
    if builtins.pathExists ./secrets/master.pub then
      builtins.replaceStrings [ "\n" "\r" ] [ "" "" ] (builtins.readFile ./secrets/master.pub)
    else
      throw "secrets/master.pub is missing; see secrets/README.md";

  recipients = {
    mikoshi = [
      master
      # Legacy user key, retained for recovery during migration.
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhIkQh2Viqa519kFJjIPUrz3jrwkSljezVlLU5GP0uh mat@homelab"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDXHRx83f5MWdhcEHXduTINyUu6yqd2eOgZHE0XNYFlO root@homelab"
    ];
    edgerunner = [
      master
      # Legacy user key, retained for recovery during migration.
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8nnsz9p+mUYkyY1LXwvEoql74kFLA36EkUtDAWhkBV mat@nixos-pc"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEDIUVIPYhK2pYTVroHvCqChkc0JL7YGfes4teME5Vb1 root@nixos-pc"
    ];
  };

  secretsByHost = {
    mikoshi = [
      "secrets/cloudflare_certbot_token.age"
      "secrets/gatus_discord_webhook_env.age"
      "secrets/homarr_env.age"
      "secrets/paperless_admin_pw.age"
      "secrets/paperless_backups_1password_token_env.age"
      "secrets/proton_wireguard_conf_server.age"
    ];
    edgerunner = [
      "secrets/proton_wireguard_conf_desktop.age"
    ];
  };
in
builtins.listToAttrs (
  builtins.concatLists (
    map (
      host:
      map (secret: {
        name = secret;
        value.publicKeys = recipients.${host};
      }) secretsByHost.${host}
    ) (builtins.attrNames secretsByHost)
  )
)
