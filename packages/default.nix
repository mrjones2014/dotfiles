{ inputs, pkgs, system, ... }: {
  waterfox-bin = pkgs.callPackage ./waterfox-bin.nix { };
  vim-zellij-navigator = pkgs.callPackage ./vim-zellij-navigator.nix { };
  zjstatus = inputs.zjstatus.packages.${system}.default;
}
