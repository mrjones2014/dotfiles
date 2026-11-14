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
        inputs.agenix-rekey.nixosModules.default
        {
          environment.systemPackages = [ inputs.agenix-rekey.packages.x86_64-linux.default ];
          age.rekey = {
            storageMode = "local";
            localStorageDir = ../. + "/secrets/rekeyed/${name}";
            masterIdentities = [
              {
                identity = ../secrets/master.age;
                pubkey = ../secrets/master.pub;
              }
            ];
          };
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
