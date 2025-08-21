{
  lib,
  stdenv,
  nix-auto-follow,
}:

stdenv.mkDerivation {
  pname = "nix-flake-inputs";
  version = "0.0.0";

  src = lib.sourceFilesBySuffices ../. [
    ".nix"
    ".lock"
  ];

  nativeBuildInputs = [
    nix-auto-follow
  ];

  buildPhase = ''
    auto-follow --check
    touch $out
  '';
}
