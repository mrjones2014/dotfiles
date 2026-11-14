{
  description = "My dotfiles managed with nix as a flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-palette = {
      url = "github:catppuccin/palette";
      flake = false;
    };
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jj-gh = {
      url = "github:mrjones2014/jj-gh/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "flake-utils/systems";
      };
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
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
    let
      myLib = import ./lib {
        inherit nixpkgs;
        inherit agenix;
        inherit home-manager;
        inherit nix-darwin;
        inherit inputs;
      };
      inherit (myLib) mkHost;
      inherit (myLib) mkDarwinHost;
    in
    {
      nixosConfigurations = {
        mikoshi = mkHost {
          name = "mikoshi";
          homePath = ./home-manager/server.nix;
        };
        edgerunner = mkHost {
          name = "edgerunner";
        };
      };
      darwinConfigurations = {
        corpo = mkDarwinHost {
          name = "corpo";
        };
        aldecaldo = mkDarwinHost {
          name = "aldecaldo";
        };
      };
    }
    // flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (
      system:
      let
        inherit (nixpkgs) lib;
        pkgs = nixpkgs.legacyPackages.${system};
        checksForConfigs =
          configs: extract:
          lib.attrsets.filterAttrs (_: p: p.system == system) (lib.attrsets.mapAttrs (_: extract) configs);
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        formatter = treefmtEval.config.build.wrapper;
        agenix-edit = pkgs.writeShellApplication {
          name = "agenix-edit";
          runtimeInputs = [ agenix.packages.${system}.default ];
          text = ''
            if [[ $# -eq 1 && ( "$1" == --help || "$1" == -h ) ]]; then
              echo "Usage: agenix-edit NAME[.age] (or secrets/NAME.age)"
              exit 0
            fi
            if [[ $# -ne 1 ]]; then
              echo "Usage: agenix-edit NAME[.age] (or secrets/NAME.age)" >&2
              exit 1
            fi
            if [[ ! -t 0 ]]; then
              echo "agenix-edit requires an interactive terminal; refusing to replace a secret from stdin" >&2
              exit 1
            fi

            root="$PWD"
            while [[ ! -f "$root/agenix-rules.nix" ]]; do
              if [[ "$root" == / ]]; then
                echo "Could not find agenix-rules.nix in this directory or its parents" >&2
                exit 1
              fi
              root="$(dirname "$root")"
            done

            name="''${1#secrets/}"
            if [[ ! "$name" =~ ^[[:alnum:]_-]+(\.age)?$ ]]; then
              echo "Expected a secret name or secrets/NAME.age" >&2
              exit 1
            fi
            [[ "$name" == *.age ]] || name="$name.age"
            if [[ ! -f "$root/secrets/master.age" ]]; then
              echo "Missing $root/secrets/master.age" >&2
              exit 1
            fi

            cd "$root"
            export AGENIX_RULES="$root/agenix-rules.nix"
            exec agenix -e "secrets/$name" -i "$root/secrets/master.age"
          '';
        };
      in
      {
        packages.book = pkgs.callPackage ./docs { };
        packages.agenix-edit = agenix-edit;

        inherit formatter;
        checks =
          (checksForConfigs self.nixosConfigurations (c: c.config.system.build.toplevel))
          // (checksForConfigs self.darwinConfigurations (c: c.system))
          // {
            formatting = treefmtEval.config.build.check self;
            lint-nix = pkgs.callPackage ./checks/lint-nix.nix { inherit pkgs self; };
            lint-lua = pkgs.callPackage ./checks/lint-lua.nix { inherit pkgs self; };
            nix-flake-inputs = pkgs.callPackage ./checks/flake-inputs.nix { };
          };

        devShells = {
          default = pkgs.mkShell {
            packages = [
              formatter
              pkgs.mdbook
              pkgs.age
              agenix.packages.${system}.default
              agenix-edit
            ];
          };
          ci = pkgs.mkShell {
            packages = [
              pkgs.nix-eval-jobs
              pkgs.nix-fast-build
            ];
          };
        };
      }
    );
}
