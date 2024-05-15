{ config, pkgs, ... }:
let
  recyclarr-syncer = pkgs.writeScriptBin "recyclarr-sync" ''
    recyclarr sync --config ${config.age.secrets.recyclarr.path}
  '';
in { home.packages = [ pkgs.recyclarr recyclarr-syncer ]; }

