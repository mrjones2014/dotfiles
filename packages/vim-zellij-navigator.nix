{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "vim-zellij-navigator";
  version = "0.2.1";

  src = fetchurl {
    url =
      "https://github.com/hiasr/vim-zellij-navigator/releases/download/${version}/vim-zellij-navigator.wasm";
    sha256 = "sha256-wpIxPkmVpoAgOsdQKYuipSlDAbsD3/n6tTuOEriJHn0=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/vim-zellij-navigator.wasm
    chmod +x $out/bin/vim-zellij-navigator.wasm
  '';

  meta = with lib; {
    description = "Vim Zellij Navigator WASM plugin";
    homepage = "https://github.com/hiasr/vim-zellij-navigator";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
