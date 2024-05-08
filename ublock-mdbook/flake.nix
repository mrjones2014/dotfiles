{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.callPackage ./. { inherit pkgs; };
        devShell = pkgs.mkShell {
          CARGO_INSTALL_ROOT = "${toString ./.}/.cargo";
          buildInputs = with pkgs; [
            cargo
            rustc
            git
            clippy
            rust-analyzer
            libiconv
          ];
        };
      });
}
