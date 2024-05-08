{ pkgs, ... }:
let manifest = (pkgs.lib.importTOML ./Cargo.toml).package;
in pkgs.rustPlatform.buildRustPackage {
  inherit (manifest) version;
  pname = manifest.name;
  cargoLock.lockFile = ./Cargo.lock;
  src = pkgs.lib.cleanSource ./.;
}
