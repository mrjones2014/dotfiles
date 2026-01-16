{
  nixpkgs,
  agenix,
  home-manager,
  nix-darwin,
  inputs,
}:
rec {
  mkSpecialArgs =
    overrides:
    {
      inherit inputs;
      isServer = false;
      isDarwin = false;
      isThinkpad = false;
      isLinux = false;
      isWorkMac = false;
    }
    // overrides;

  mkHost =
    {
      name,
      isServer ? false,
      isThinkpad ? false,
      homePath ? ../home-manager/home.nix,
    }:
    let
      specialArgs = mkSpecialArgs {
        inherit isServer isThinkpad;
        isLinux = true;
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
        ../nixos/common.nix
        ../hosts/${name}
        { networking.hostName = name; }
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            backupFileExtension = "backup";
            useGlobalPkgs = true;
            useUserPackages = true;
            users.mat = import homePath;
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    };
  mkDarwinHost =
    {
      name,
      homePath ? ../home-manager/home.nix,
      isWorkMac ? false,
    }:
    let
      specialArgs = mkSpecialArgs {
        isDarwin = true;
        inherit isWorkMac;
      };
    in
    nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      modules = [
        ../hosts/${name}
        ../nix-darwin/common.nix
        { networking.hostName = name; }
        home-manager.darwinModules.default
        {
          home-manager = {
            backupFileExtension = "backup";
            useGlobalPkgs = true;
            useUserPackages = true;
            users.mat = import homePath;
            extraSpecialArgs = specialArgs;
          };
        }
      ];
    };
}
