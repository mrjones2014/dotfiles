{
  pkgs,
  self,
}:
pkgs.runCommand "lint-nix"
  {
    nativeBuildInputs = [
      pkgs.statix
      pkgs.deadnix
    ];
  }
  ''
    statix check ${self}
    deadnix --fail ${self}
    touch $out
  ''
