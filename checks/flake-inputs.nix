{
  lib,
  stdenv,
  auto-follow,
}:

stdenv.mkDerivation {
  pname = "nix-flake-inputs";
  version = "0.0.0";

  src = lib.sourceFilesBySuffices ../. [
    ".nix"
    ".lock"
  ];

  nativeBuildInputs = [
    auto-follow
  ];

  buildPhase = ''
    auto-follow --check
    touch $out
  '';
}
