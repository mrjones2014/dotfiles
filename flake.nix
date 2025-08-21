{
  description = "My dotfiles managed with nix as a flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    tokyonight-nix.url = "github:mrjones2014/tokyonight.nix";
    nix-auto-follow = {
      url = "github:fzakaria/nix-auto-follow";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      nix-auto-follow,
      ...
    }:
    let
      my_lib = import ./lib {
        inherit nixpkgs;
        inherit agenix;
        inherit home-manager;
        inherit nix-darwin;
        inherit inputs;
      };
      inherit (my_lib) mkHost;
      inherit (my_lib) mkDarwinHost;
    in
    {
      nixosConfigurations = {
        homelab = mkHost {
          name = "homelab";
          isServer = true;
          homePath = ./home-manager/server.nix;
        };
        tower = mkHost {
          name = "tower";
          homePath = ./home-manager/home.nix;
        };
        nixbook = mkHost {
          name = "nixbook";
          isThinkpad = true;
          homePath = ./home-manager/home.nix;
        };
      };
      darwinConfigurations."darwin" = mkDarwinHost {
        name = "darwin";
        homePath = ./home-manager/home.nix;
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
        packages.book = pkgs.callPackage ./docs { };

        inherit formatter;
        checks =
          (checksForConfigs self.nixosConfigurations (c: c.config.system.build.toplevel))
          // (checksForConfigs self.darwinConfigurations (c: c.system))
          // {
            formatting = treefmtEval.config.build.check self;
            nix-flake-inputs = pkgs.callPackage ./checks/flake-inputs.nix {
              inherit lib;
              inherit (pkgs) stdenv;
              nix-auto-follow = nix-auto-follow.packages.${system}.default;
            };
          };

        devShells = {
          default = pkgs.mkShell {
            packages = [
              formatter
              pkgs.mdbook
              nix-auto-follow.packages.${system}.default
            ];
          };
          ci = pkgs.mkShell {
            packages = [
              pkgs.nix-fast-build
              nix-auto-follow.packages.${system}.default
            ];
          };
        };
      }
    );
}
