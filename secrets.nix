# This module is NOT imported into the NixOS config,
# it is only used by the agenix CLI to determine which
# keys to use to encrypt secrets.
let
  # my public key
  users = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhIkQh2Viqa519kFJjIPUrz3jrwkSljezVlLU5GP0uh mat@nixos"
  ];
  # server host key
  systems = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDXHRx83f5MWdhcEHXduTINyUu6yqd2eOgZHE0XNYFlO root@nixos-server"
  ];
  secrets = [
    "secrets/mullvad_wireguard.age"
    "secrets/wireguard_server.age"
    "secrets/cleanuperr_env.age"
    "secrets/homarr_env.age"
    "secrets/cloudflare_certbot_token.age"
    "secrets/duckdns_token.age"
    "secrets/gatus_discord_webhook_env.age"
    "secrets/paperless_admin_pw.age"
    "secrets/affine_env.age"
    "secrets/docmost_env.age"
  ];
in
builtins.listToAttrs (
  map (secret: {
    name = secret;
    value = {
      publicKeys = users ++ systems;
    };
  }) secrets
)
