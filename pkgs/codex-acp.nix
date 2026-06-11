{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  openssl,
  zlib,
}:
let
  version = "0.16.0";
  targets = {
    aarch64-darwin = {
      name = "aarch64-apple-darwin";
      hash = "sha256-N38RN5RbVNjmictgB2f23P5uVI4BwfKQGIYsAJxpLI0=";
    };
    aarch64-linux = {
      name = "aarch64-unknown-linux-gnu";
      hash = "sha256-y3KCD1PJGmOYKoBL1qslG95RvJNx2OY4lG8C19eFgLU=";
    };
    x86_64-darwin = {
      name = "x86_64-apple-darwin";
      hash = "sha256-IS+vz5ccdc1PUGC+LVlRvDIvccSQKNvSUxkxSUwzx4Q=";
    };
    x86_64-linux = {
      name = "x86_64-unknown-linux-gnu";
      hash = "sha256-CprWwx7Jsrh9zLfp2j+vXTh+dEcNJNvO11oWDteyLQY=";
    };
  };
  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "codex-acp: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "codex-acp";
  inherit version;

  src = fetchurl {
    url = "https://github.com/zed-industries/codex-acp/releases/download/v${version}/codex-acp-${version}-${target.name}.tar.gz";
    inherit (target) hash;
  };

  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    openssl
    zlib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 codex-acp "$out/bin/codex-acp"
    if [ -d codex-resources ]; then
      cp -r codex-resources "$out/bin/"
    fi

    runHook postInstall
  '';

  meta = {
    description = "An ACP-compatible coding agent powered by Codex";
    homepage = "https://github.com/zed-industries/codex-acp";
    changelog = "https://github.com/zed-industries/codex-acp/releases/tag/v${version}";
    license = lib.licenses.asl20;
    platforms = builtins.attrNames targets;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "codex-acp";
  };
}
