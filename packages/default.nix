{ inputs, pkgs, system, ... }: {
  waterfox-bin = pkgs.callPackage ./waterfox-bin.nix { };
  zjstatus = inputs.zjstatus.packages.${system}.default;
}
