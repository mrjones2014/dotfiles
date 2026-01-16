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
    "signal"
    "vesktop"
    "proton-mail-bridge"
    "unifi-identity-endpoint"
    "proton-drive"
  ];
}
