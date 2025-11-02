{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "zjstatus";
  version = "0.21.1";

  # These are independent derivations, not the main "src"
  zjstatusSrc = fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v${version}/zjstatus.wasm";
    sha256 = "sha256-3BmCogjCf2aHHmmBFFj7savbFeKGYv3bE2tXXWVkrho=";
  };

  zjframesSrc = fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v${version}/zjframes.wasm";
    sha256 = "sha256-oNlOQcP7zV94JFi0HDIePpyxI+MUDf+yBghSatL60RY=";
  };

  # Disable automatic unpacking — these are plain files
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ${zjstatusSrc} $out/bin/zjstatus.wasm
    cp ${zjframesSrc} $out/bin/zjframes.wasm
    chmod +x $out/bin/*.wasm
  '';

  meta = with lib; {
    description = "zjstatus and zjframes WASM plugins for Zellij";
    homepage = "https://github.com/dj95/zjstatus";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
