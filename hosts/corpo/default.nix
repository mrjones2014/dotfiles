{ config, pkgs, ... }:
{
  users.users.mat = {
    name = "mat.jones"; # username is set by MDM on work mac :/
    home = "/Users/mat.jones";
    shell = pkgs.fish;
  };
  # Work-specific homebrew casks
  homebrew.casks = [
    "waterfox"
    "xcodes-app"
    "docker-desktop"
  ];
  home-manager.users.mat.dotfiles.work = true;
  system.primaryUser = config.users.users.mat.name;
  system.stateVersion = 6;
}
