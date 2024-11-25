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

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, ... }:
    let
      mkNixosConfig = { extraSpecialArgs, extraModules }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            isLinux = true;
            isDarwin = false;
            # override these in extraSpecialArgs
            isThinkpad = false;
            isServer = false;
          } // extraSpecialArgs;
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            ./nixos-modules/common.nix
            {
              home-manager = {
                backupFileExtension = "backup";
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit inputs;
                  isDarwin = false;
                  isLinux = true;
                } // extraSpecialArgs;
              };
            }
          ] ++ extraModules;
        };
    in {
      nixosConfigurations = {
        server = mkNixosConfig {
          extraSpecialArgs = { isServer = true; };
          extraModules = [
            ./hosts/server
            agenix.nixosModules.default
            {
              environment.systemPackages =
                [ agenix.packages.x86_64-linux.default ];
            }
          ];
        };
        pc = mkNixosConfig {
          extraSpecialArgs = { };
          extraModules = [ ./hosts/pc ];
        };
        laptop = mkNixosConfig {
          extraSpecialArgs = { isThinkpad = true; };
          extraModules = [ ./hosts/laptop ];
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
