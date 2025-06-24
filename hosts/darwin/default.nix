{ config, pkgs, ... }:
{
  imports = [
    ../../nixos/nix-conf.nix
    ./settings.nix
  ];
  nix.optimise.automatic = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  programs.fish.enable = true;
  networking.hostName = "darwin";
  users.users.mat = {
    name = "mat.jones"; # username is set by MDM on work mac :/
    home = "/Users/mat.jones";
    shell = pkgs.fish;
  };
  environment.variables.HOMEBREW_NO_ANALYTICS = "1";
  environment.systemPath = [ "/opt/homebrew/bin" ];
  homebrew = {
    enable = true;
    casks = [
      "espanso"
      "ghostty"
      "zen"
      "waterfox"
      "rectangle-pro"
      "alfred"
      "xcodes-app"
    ];
  };
  system.primaryUser = config.users.users.mat.name;
  system.stateVersion = 6;
}
