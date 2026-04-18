{ config, pkgs, ... }:
{
  users.users.mat = {
    name = "mat";
    home = "/Users/mat";
    shell = pkgs.fish;
  };
  system.primaryUser = config.users.users.mat.name;
  system.stateVersion = 6;
  homebrew.casks = [
    "proton-mail-bridge"
    "signal"
    "todoist-app"
    "unifi-identity-endpoint"
    "vesktop"
  ];
}
