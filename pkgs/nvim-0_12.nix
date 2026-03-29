# TODO: Remove this package once neovim 0.12 is available in nixpkgs
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/neovim/neovim/releases/download/v0.12.0/nvim-linux-x86_64.tar.gz";
      hash = "sha256-FgtpEl3vsW5gsoO2m+ES/UhQ1nrI+adSMowgrUPsNK8=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/neovim/neovim/releases/download/v0.12.0/nvim-macos-arm64.tar.gz";
      hash = "TODO fix when I'm at a macOS machine";
    };
  };
in
stdenv.mkDerivation {
  pname = "neovim";
  version = "0.12.0";

  src = sources.${stdenv.system} or (throw "Unsupported system: ${stdenv.system}");

  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    mkdir -p $out
    cp -r nvim-*/. $out/
  '';

  meta = with lib; {
    description = "Neovim";
    longDescription = "Neovim 0.12.0 (prebuilt binary)";
    homepage = "https://github.com/neovim/neovim";
    mainProgram = "nvim";
    teams = { };
    license = licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
