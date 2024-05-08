{ pkgs, system, ublock-mdbook, ... }:
/* let
     highlightJsNix = pkgs.fetchFromGitHub {
       owner = "mrjones2014";
       repo = "highlight-js-nix";
       rev = "67aebab";
       sha256 = "0k6fn27jq5zjinqz2shinb68f50pwhccmlq89digpqxxhafvr5g1";
     };
   in
*/
pkgs.stdenv.mkDerivation {
  pname = "mdbook-docs-site";
  version = "0.1.0";
  src = pkgs.lib.cleanSource ./.;
  buildInputs = [ pkgs.mdbook ublock-mdbook.packages.${system}.default ];
  # cp ${highlightJsNix}/highlight.js ./theme/
  buildPhase = ''
    mkdir $out
    mdbook build -d $out
    ublock-mdbook gen-filter-list $out/ublock-filters.txt
  '';
}
