{
  description = "My dotfiles managed with nix as a flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    tokyonight.url = "github:mrjones2014/tokyonight.nix";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      nix-darwin,
      home-manager,
      agenix,
      ...
    }:
    {
      nixosConfigurations = {
        homelab =
          let
            specialArgs = {
              inherit inputs;
              isServer = true;
              isLinux = true;
              isThinkpad = false;
              isDarwin = false;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            modules = [
              home-manager.nixosModules.home-manager
              agenix.nixosModules.default
              {
                environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
              }
              ./nixos/common.nix
              ./hosts/homelab
              {
                home-manager = {
                  backupFileExtension = "backup";
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.mat = import ./home-manager/server.nix;
                  extraSpecialArgs = specialArgs;
                };
              }
            ];
          };
        tower =
          let
            specialArgs = {
              inherit inputs;
              isServer = false;
              isDarwin = false;
              isLinux = true;
              isThinkpad = false;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            modules = [
              agenix.nixosModules.default
              {
                environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
              }
              ./nixos/common.nix
              ./hosts/tower
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  backupFileExtension = "backup";
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.mat = import ./home-manager/home.nix;
                  extraSpecialArgs = specialArgs;
                };
              }
            ];
          };
        nixbook =
          let
            specialArgs = {
              inherit inputs;
              isServer = false;
              isDarwin = false;
              isLinux = true;
              isThinkpad = true;
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            modules = [
              ./nixos/common.nix
              ./hosts/nixbook
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  backupFileExtension = "backup";
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.mat = import ./home-manager/home.nix;
                  extraSpecialArgs = specialArgs;
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
                backupFileExtension = "backup";
                useGlobalPkgs = true;
                useUserPackages = true;
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
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        formatter = treefmtEval.config.build.wrapper;
      in
      {
        inherit formatter;
        checks =
          (checksForConfigs self.nixosConfigurations (c: c.config.system.build.toplevel))
          // (checksForConfigs self.darwinConfigurations (c: c.system))
          // {
            formatting = treefmtEval.config.build.check self;
          };
        devShells = {
          default = pkgs.mkShell { packages = [ formatter ]; };
          ci = pkgs.mkShell {
            packages = [ pkgs.nix-fast-build ];
          };
        };
      }
    );
}
