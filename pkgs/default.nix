{
  pkgs,
  ...
}:
{
  vim-zellij-navigator = pkgs.callPackage ./vim-zellij-navigator.nix { };
  zjstatus = pkgs.callPackage ./zjstatus.nix { };
}
