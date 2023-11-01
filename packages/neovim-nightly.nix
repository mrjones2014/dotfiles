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
  # custom patch required for bulding on macOS
  # see: https://github.com/nix-community/neovim-nightly-overlay/issues/176
  # see: https://github.com/hurricanehrndz/nixcfg/commit/69e37b6ef878ddba8a8af1bd514f967879ea0082
  patches = builtins.filter (p:
    (if builtins.typeOf p == "set" then baseNameOf p.name else baseNameOf)
    != "use-the-correct-replacement-args-for-gsub-directive.patch") o.patches;
  nativeBuildInputs = o.nativeBuildInputs ++ lib.optionals isDarwin [ liblpeg ];
  # Neovim GitHub org has a mirror of libvterm that tags releases before they're
  # available upstream; use Neovim's libvterm mirror.
  buildInputs = lib.lists.remove pkgs.libvterm-neovim o.buildInputs ++ [
    (pkgs.callPackage ./libvterm-neovim.nix { inherit (pkgs) libvterm-neovim; })
  ];
})
