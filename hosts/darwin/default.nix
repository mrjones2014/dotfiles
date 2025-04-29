{ pkgs, ... }: {
  imports = [ ../../nixos/nix-conf.nix ./settings.nix ];
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
  };
  system.stateVersion = 6;
}
