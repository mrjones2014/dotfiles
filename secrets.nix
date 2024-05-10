# This module is NOT imported into the NixOS config,
# it is only used by the agenix CLI to determine which
# keys to use to encrypt secrets.
let
  # my public key
  users = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsT6GLG7sY8YKX7JM+jqS3EAti3YMzwHKWViveqkZvu"
  ];
  # server host key
  systems = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUa3f8x3mb2fHF5JXjGKdWF5EUX8GQj7hMhEUn7LffI root@nixos-server"
  ];
in { "mullvad_wireguard.age".publicKeys = users ++ systems; }

