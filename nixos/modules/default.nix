{ ... }:
{
  imports = [
    ./_1password.nix
    ./_1password-linux.nix
    ./nginx.nix
    ./proton-backup.nix
    ./qbittorrent.nix
    ./unfree.nix
  ];
}
