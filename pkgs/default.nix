{
  pkgs,
  ...
}:
{
  vim-zellij-navigator = pkgs.callPackage ./vim-zellij-navigator.nix { };
  zjstatus = pkgs.callPackage ./zjstatus.nix { };
  gh-1p = import ./gh-1p.nix { inherit pkgs; };
}
