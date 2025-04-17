{
  description = "My dotfiles managed with nix as a flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    tokyonight.url = "github:mrjones2014/tokyonight.nix";
    zjstatus.url = "github:dj95/zjstatus";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nix-darwin, home-manager, agenix, ... }: {
    nixosConfigurations = {
      server = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          isServer = true;
          isLinux = true;
          isThinkpad = false;
          isDarwin = false;
        };
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          {
            environment.systemPackages =
              [ agenix.packages.x86_64-linux.default ];
          }
          ./nixos/common.nix
          ./hosts/server
          {
            home-manager = {
              backupFileExtension = "backup";
              useUserPackages = true;
              users.mat = import ./home-manager/server.nix;
              extraSpecialArgs = {
                inherit inputs;
                isServer = true;
                isLinux = true;
                isThinkpad = false;
                isDarwin = false;
              };
            };
          }
        ];
      };
      pc = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          isServer = false;
          isDarwin = false;
          isLinux = true;
          isThinkpad = false;
        };
        system = "x86_64-linux";
        modules = [
          ./nixos/common.nix
          ./hosts/pc
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "backup";
              useUserPackages = true;
              users.mat = import ./home-manager/home.nix;
              extraSpecialArgs = {
                inherit inputs;
                isServer = false;
                isDarwin = false;
                isLinux = true;
                isThinkpad = false;
              };
            };
          }
        ];
      };
      laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          isServer = false;
          isDarwin = false;
          isLinux = true;
          isThinkpad = true;
        };
        system = "x86_64-linux";
        modules = [
          ./nixos/common.nix
          ./hosts/laptop
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "backup";
              useUserPackages = true;
              users.mat = import ./home-manager/home.nix;
              extraSpecialArgs = {
                inherit inputs;
                isServer = false;
                isDarwin = false;
                isLinux = true;
                isThinkpad = true;
              };
            };
          }
        ];
      };
    };
    darwinConfigurations."Mats-MacBook-Pro" =
      let
        specialArgs = {
          inherit inputs;
          isServer = false;
          isDarwin = true;
          isLinux = false;
          isThinkpad = false;
        };
      in
      nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        pkgs = nixpkgs.legacyPackages."aarch64-darwin";
        modules = [
          ./hosts/darwin
          home-manager.darwinModules.default
          {
            home-manager = {
              users.mat = import ./home-manager/home.nix;
              extraSpecialArgs = specialArgs;
            };
          }
        ];
      };
  };
}
