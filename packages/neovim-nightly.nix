{ neovim, pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  liblpeg = pkgs.stdenv.mkDerivation {
    pname = "liblpeg";
    inherit (pkgs.luajitPackages.lpeg) version meta src;

    buildInputs = [ pkgs.luajit ];

    buildPhase = ''
      sed -i makefile -e "s/CC = gcc/CC = clang/"
      sed -i makefile -e "s/-bundle/-dynamiclib/"
      make macosx
    '';

    installPhase = ''
      mkdir -p $out/lib
      mv lpeg.so $out/lib/lpeg.dylib
    '';

    nativeBuildInputs = [ pkgs.fixDarwinDylibNames ];
  };
in neovim.overrideAttrs (o: {
  patches = builtins.filter (p:
    (if builtins.typeOf p == "set" then baseNameOf p.name else baseNameOf)
    != "use-the-correct-replacement-args-for-gsub-directive.patch") o.patches;
  nativeBuildInputs = o.nativeBuildInputs ++ lib.optionals isDarwin [ liblpeg ];
})
