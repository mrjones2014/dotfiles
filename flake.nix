{
  description = "My dotfiles managed with nix as a flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    tokyonight.url = "github:mrjones2014/tokyonight.nix";
    zjstatus.url = "github:dj95/zjstatus";
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
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://mrjones2014-dotfiles.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "mrjones2014-dotfiles.cachix.org-1:c66wfzthG6KZEWnltlzW/EjhlH9FwUVi5jM4rVD1Rw4="
    ];
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, ... }: {
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
          ./nixos-modules/common.nix
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
          ./nixos-modules/common.nix
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
          ./nixos-modules/common.nix
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
    homeConfigurations = {
      "mac" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          inherit inputs;
          isServer = false;
          isDarwin = true;
          isLinux = false;
          isThinkpad = false;
        };
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./home-manager/home.nix ];
      };
    };
  };
}
