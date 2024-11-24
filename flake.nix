{
  description = "My dotfiles managed with nix as a flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";
    tokyonight.url = "github:mrjones2014/tokyonight.nix";
    wezterm-nightly = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arkenfox = {
      url = "github:dwarfmaster/arkenfox-nixos";
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

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, ... }: {
    nixosConfigurations = {
      server = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          isServer = true;
          isLinux = true;
	  isLaptop = false;
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
		isLaptop = false;
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
	  isLaptop = false;
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
		isLaptop = false;
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
	  isLaptop = true;
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
		isLaptop = true;
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
        };
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./home-manager/home.nix ];
      };
    };
  };
}
