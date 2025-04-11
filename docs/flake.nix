{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ublock-mdbook = import ../ublock-mdbook { inherit pkgs; };
      in
      {
        packages.default = pkgs.callPackage ./. {
          inherit pkgs;
          inherit system;
          inherit ublock-mdbook;
        };
        devShells.default =
          pkgs.mkShell { buildInputs = [ pkgs.mdbook ublock-mdbook ]; };
      });
}
