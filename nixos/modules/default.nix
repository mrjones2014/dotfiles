{ ... }:
{
  imports = [
    ./_1password.nix
    ./_1password-linux.nix
    ./nginx.nix
    ./qbittorrent.nix
    ./unfree.nix
  ];
}
