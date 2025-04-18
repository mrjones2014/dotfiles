{ inputs, pkgs, system, ... }: {
  vim-zellij-navigator = pkgs.callPackage ./vim-zellij-navigator.nix { };
  zjstatus = inputs.zjstatus.packages.${system}.default;
  zen-browser = inputs.zen-browser.packages.${system}.default;
  darwin-rebuild = inputs.nix-darwin.packages."aarch64-darwin".default;
}
