{
  description = "My dotfiles managed with nix as a flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arkenfox = {
      url = "github:dwarfmaster/arkenfox-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    _1password-shell-plugins.url = "github:1Password/shell-plugins";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      # server = nixpkgs.lib.nixosSystem {
      #   specialArgs = { inherit inputs; };
      #   system = "x86_64-linux";
      #   modules = [
      #     ./nixos-modules/common.nix
      #     ./hosts/server/default.nix
      #     home-manager.nixosModules.home-manager
      #     {
      #       home-manager = {
      #         useUserPackages = true;
      #         users.mat = import ./home-manager/server.nix;
      #         extraSpecialArgs = { inherit inputs; };
      #       };
      #     }
      #   ];
      # };
      pc = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [
          ./nixos-modules/common.nix
          ./hosts/pc/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              users.mat = import ./home-manager/home.nix;
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      };
    };
    homeConfigurations = {
      "mac" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { inherit inputs; };
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ inputs.arkenfox.hmModules.default ./home-manager/home.nix ];
      };
    };
  };
}
