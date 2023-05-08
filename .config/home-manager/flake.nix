{
  description = "My dotfiles managed with nix as a flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin.url = "github:lnl7/nix-darwin";
    mkalias.url = "github:reckenrode/mkalias";
  };

  outputs = { nixpkgs, home-manager, darwin, mkalias, ... }: {
    defaultPackage.aarch64-darwin = home-manager.defaultPackage.aarch64-darwin;
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
    homeConfigurations = {
      "mat" = home-manager.lib.homeManagerConfiguration {
        pkgs = if builtins.currentSystem == "aarch64-darwin" then
          nixpkgs.legacyPackages.aarch64-darwin
        else
          nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ];
      };
    };
  };
}
