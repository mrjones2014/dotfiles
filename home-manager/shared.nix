{ pkgs, lib, ... }: {
  nix.package = lib.mkDefault pkgs.lix;
  theme = "tokyonight";
  imports = [
    ../nixos-modules/theme.nix
    ./modules/fish.nix
    ./modules/nvim.nix
    ./modules/ssh.nix
    ./modules/starship.nix
    ./modules/git.nix
    ./modules/fzf.nix
    ./modules/bat.nix
  ];
}
