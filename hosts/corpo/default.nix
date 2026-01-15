{ config, pkgs, ... }:
{
  networking.hostName = "corpo";
  users.users.mat = {
    name = "mat.jones"; # username is set by MDM on work mac :/
    home = "/Users/mat.jones";
    shell = pkgs.fish;
  };
  # Work-specific homebrew casks
  homebrew.casks = [
    "waterfox"
    "rectangle-pro"
    "xcodes-app"
    "docker-desktop"
  ];
  system.primaryUser = config.users.users.mat.name;
  system.stateVersion = 6;
}
