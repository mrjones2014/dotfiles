{
  pkgs,
  inputs,
  ...
}:
{
  agenix-edit = import ./agenix-edit.nix {
    inherit pkgs;
    agenix-rekey = inputs.agenix-rekey.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
  gh-1p = import ./gh-1p.nix { inherit pkgs; };
}
