{
  pkgs,
  ...
}:
{
  codex-acp = pkgs.callPackage ./codex-acp.nix { };
  gh-1p = import ./gh-1p.nix { inherit pkgs; };
}
