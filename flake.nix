{
  description = "My dotfiles managed with nix as a flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    tokyonight.url = "github:mrjones2014/tokyonight.nix";
    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  nixConfig = {
    extra-substituters = [ "https://mrjones2014-dotfiles.cachix.org" ];
    extra-trusted-public-keys = [
      "mrjones2014-dotfiles.cachix.org-1:c66wfzthG6KZEWnltlzW/EjhlH9FwUVi5jM4rVD1Rw4="
    ];
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      nix-darwin,
      home-manager,
      agenix,
      ...
    }:
    {
      nixosConfigurations = {
        homelab = nixpkgs.lib.nixosSystem {
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
              environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
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
        tower = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            isServer = false;
            isDarwin = false;
            isLinux = true;
            isThinkpad = false;
          };
          system = "x86_64-linux";
          modules = [
            agenix.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
            }
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
        nixbook = nixpkgs.lib.nixosSystem {
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
      darwinConfigurations."darwin" =
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
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit (nixpkgs) lib;
        pkgs = nixpkgs.legacyPackages.${system};
        checksForConfigs =
          configs: extract:
          lib.attrsets.filterAttrs (_: p: p.system == system) (lib.attrsets.mapAttrs (_: extract) configs);
      in
      {
        checks =
          (checksForConfigs self.nixosConfigurations (c: c.config.system.build.toplevel))
          // (checksForConfigs self.darwinConfigurations (c: c.system));
        devShells.ci = pkgs.mkShell {
          packages = [ pkgs.nix-fast-build ];
        };
      }
    );
}
