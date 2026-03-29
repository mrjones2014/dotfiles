{
  pkgs,
  ...
}:
{
  vim-zellij-navigator = pkgs.callPackage ./vim-zellij-navigator.nix { };
  zjstatus = pkgs.callPackage ./zjstatus.nix { };
  # TODO: Remove once neovim 0.12 is available in nixpkgs
  nvim-0_12 = pkgs.callPackage ./nvim-0_12.nix { };
}
