{
  inputs,
  pkgs,
  system,
  ...
}:
{
  vim-zellij-navigator = pkgs.callPackage ./vim-zellij-navigator.nix { };
  zjstatus = inputs.zjstatus.packages.${system}.default;
}
