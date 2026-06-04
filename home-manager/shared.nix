{ config, ... }:
{
  home = {
    preferXdgDirectories = true;
    sessionVariables = {
      MANPAGER = "nvim -c 'Man!' -o -";
      PAGER = "less -FRX";
    };
  };
  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/git/dotfiles/";
    clean = {
      enable = true;
      extraArgs = "--keep 3";
    };
  };
  imports = [
    (import ../nixos/nix-conf.nix { isHomeManager = true; })
    ../nixos/theme.nix
    ./components/fish.nix
    ./components/nvim.nix
    ./components/ssh.nix
    ./components/starship.nix
    ./components/vcs
    ./components/fzf.nix
  ];
}
