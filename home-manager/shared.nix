{
  imports = [
    ../nixos/nix-conf.nix
    ../nixos/theme.nix
    ./modules/fish.nix
    ./modules/nvim.nix
    ./modules/ssh.nix
    ./modules/starship.nix
    ./modules/git.nix
    ./modules/fzf.nix
  ];
}
