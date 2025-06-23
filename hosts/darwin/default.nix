{ config, pkgs, ... }:
{
  imports = [
    ../../nixos/nix-conf.nix
    ./settings.nix
  ];
  nix.optimise.automatic = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  programs.fish.enable = true;
  users.users.mat = {
    name = "mat";
    home = "/Users/mat";
    shell = pkgs.fish;
  };
  environment.variables.HOMEBREW_NO_ANALYTICS = "1";
  environment.systemPath = [ "/opt/homebrew/bin" ];
  homebrew = {
    enable = true;
    taps = [ "kiraum/tap" ];
    brews = [ "kiraum/tap/cody" ];
    casks = [ "espanso" ];
  };
  system.primaryUser = config.users.users.mat.name;
  system.stateVersion = 6;
}
