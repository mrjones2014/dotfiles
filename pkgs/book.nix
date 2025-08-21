{
  pkgs,
  lib,
  ...
}:
let
  highlightJsNix = pkgs.fetchFromGitHub {
    owner = "mrjones2014";
    repo = "highlight-js-nix";
    rev = "67aebab";
    hash = "sha256-EmeiP7TAdb7n6KOHJ8qhGzSL0TGkoVuQIkijnrAj5RQ=";
  };

  # Create the ublock preprocessor script
  ublockPreprocessor = pkgs.writeShellScriptBin "ublock-mdbook" ''
    export UBLOCK_FILTERS_YAML="${../docs/src/ublock-filters.yml}"
    exec ${pkgs.bash}/bin/bash ${./ublock-mdbook-preprocessor.sh} "$@"
  '';
in
pkgs.stdenv.mkDerivation {
  pname = "mdbook-docs-site";
  version = "0.1.0";
  src = lib.cleanSource ../docs;
  
  nativeBuildInputs = [
    pkgs.mdbook
    pkgs.yq-go
    pkgs.jq
    ublockPreprocessor
  ];
  
  buildPhase = ''
    mkdir -p $out
    
    # Copy the source to a temporary build directory
    cp -r . build-dir
    cd build-dir
    
    # Build the book
    mdbook build -d $out
    
    # Replace highlight.js with the custom one
    rm -f $out/highlight.js
    cp ${highlightJsNix}/highlight.js $out/highlight.js
    
    # Generate the filter list
    ublock-mdbook gen-filter-list $out/ublock-filters.txt
  '';
  
  meta = with lib; {
    description = "Documentation site built with mdbook";
    license = licenses.mit;
    platforms = platforms.all;
  };
}