{ pkgs, system, ublock-mdbook, ... }:
let
  highlightJsNix = pkgs.fetchFromGitHub {
    owner = "mrjones2014";
    repo = "highlight-js-nix";
    rev = "67aebab";
    hash = "sha256-EmeiP7TAdb7n6KOHJ8qhGzSL0TGkoVuQIkijnrAj5RQ=";
  };
in pkgs.stdenv.mkDerivation {
  pname = "mdbook-docs-site";
  version = "0.1.0";
  src = pkgs.lib.cleanSource ./.;
  buildInputs = [ pkgs.mdbook ublock-mdbook.packages.${system}.default ];
  buildPhase = ''
    mkdir $out
    mdbook build -d $out
    rm $out/highlight.js && cp ${highlightJsNix}/highlight.js $out/highlight.js
    ublock-mdbook gen-filter-list $out/ublock-filters.txt
  '';
}
