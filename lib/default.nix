{
  nixpkgs,
  agenix,
  home-manager,
  nix-darwin,
  inputs,
}:
{

  mkHost =
    {
      name,
      homePath ? ../home-manager/home.nix,
    }:
    let
      specialArgs = { inherit inputs; };
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
    }:
    let
      specialArgs = { inherit inputs; };
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
