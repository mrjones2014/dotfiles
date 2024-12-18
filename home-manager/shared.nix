{ pkgs, lib, ... }: {
  nix = {
    package = lib.mkDefault pkgs.lix;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
  };
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
