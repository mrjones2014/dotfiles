# This module is NOT imported into the NixOS config,
# it is only used by the agenix CLI to determine which
# keys to use to encrypt secrets.
let
  # my public key
  users = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDXHRx83f5MWdhcEHXduTINyUu6yqd2eOgZHE0XNYFlO mat@nixos-server"
  ];
  # server host key
  systems = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUa3f8x3mb2fHF5JXjGKdWF5EUX8GQj7hMhEUn7LffI root@nixos-server"
  ];
in {
  "secrets/mullvad_wireguard.age".publicKeys = users ++ systems;
  "secrets/homepage.age".publicKeys = users ++ systems;
  "secrets/wireguard_server.age".publicKeys = users ++ systems;
  "secrets/cleanuperr_env.age".publicKeys = users ++ systems;
  "secrets/nextcloud_admin_pass.age".publicKeys = users ++ systems;
}
