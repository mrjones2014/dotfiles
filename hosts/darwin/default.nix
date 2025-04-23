{ pkgs, ... }: {
  imports = [ ../../nixos/nix-conf.nix ./settings.nix ];
  nixpkgs.hostPlatform = "aarch64-darwin";
  programs.fish.enable = true;
  users.users.mat = {
    name = "mat";
    home = "/Users/mat";
    shell = pkgs.fish;
  };
  system = {
    stateVersion = 6;
  };
}
