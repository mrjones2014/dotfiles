{
  description = "My dotfiles managed with nix as a flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-flake = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arkenfox = {
      url = "github:dwarfmaster/arkenfox-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      pc = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          vars = (import ./lib/vars.nix) { isDarwin = false; };
        };
        system = "x86_64-linux";
        modules = [
          ./nixos-modules/common.nix
          ./hosts/pc/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.mat = import ./home-manager/home.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              vars = (import ./lib/vars.nix) { isDarwin = false; };
            };
          }
        ];
      };
    };
    homeConfigurations = {
      "mac" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          inherit inputs;
          vars = (import ./lib/vars.nix) { isDarwin = true; };
        };
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [
          ./home-manager/home.nix
          arkenfox.hmModules.default
        ];
      };
    };
  };
}
