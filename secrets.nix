# This module is NOT imported into the NixOS config,
# it is only used by the agenix CLI to determine which
# keys to use to encrypt secrets.
let
  # my public key
  users = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDhIkQh2Viqa519kFJjIPUrz3jrwkSljezVlLU5GP0uh mat@homelab"
  ];
  # server host key
  systems = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDXHRx83f5MWdhcEHXduTINyUu6yqd2eOgZHE0XNYFlO root@homelab"
  ];
  secrets = [
    "secrets/mullvad_wireguard.age"
    "secrets/cleanuperr_env.age"
    "secrets/homarr_env.age"
    "secrets/cloudflare_certbot_token.age"
    "secrets/gatus_discord_webhook_env.age"
    "secrets/paperless_admin_pw.age"
    "secrets/docmost_env.age"
    "secrets/donetick_config.age"
    "secrets/paperless_backups_1password_token_env.age"
  ];
in
(builtins.listToAttrs (
  map (secret: {
    name = secret;
    value = {
      publicKeys = users ++ systems;
    };
  }) secrets
))
// {
  # Secrets for desktop PC, not server
  "secrets/mullvad_wireguard_desktop.age".publicKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8nnsz9p+mUYkyY1LXwvEoql74kFLA36EkUtDAWhkBV mat@nixos-pc"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEDIUVIPYhK2pYTVroHvCqChkc0JL7YGfes4teME5Vb1 root@nixos-pc"
  ];
}
