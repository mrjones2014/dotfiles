{
  system.stateVersion = 6;
  imports = [ ../../nixos-modules/nix-conf.nix ];
  nixpkgs.hostPlatform = "aarch64-darwin";
  users.users.mat = {
    name = "mat";
    home = "/Users/mat";
  };
}
