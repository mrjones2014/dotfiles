{
  pkgs,
  ...
}:
{
  gh-1p = import ./gh-1p.nix { inherit pkgs; };
}
