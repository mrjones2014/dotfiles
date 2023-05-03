# copies macOS *.app bundles into /Applications/
{ config, inputs, lib, pkgs, system, ... }:
let inherit (inputs) mkalias;
in {
  disabledModules = [ "targets/darwin/linkapps.nix" ];
  home.activation.aliasApplications = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
    (let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      echo "Linking Home Manager applications..." 2>&1
      app_path="$HOME/Applications/Home Manager Apps"
      tmp_path="$(mktemp -dt "home-manager-applications.XXXXXXXXXX")" || exit 1
      ${pkgs.fd}/bin/fd \
        -t l -d 1 . ${apps}/Applications \
        -x $DRY_RUN_CMD ${mkalias} -L {} "$tmp_path/{/}"
      $DRY_RUN_CMD rm -rf "$app_path"
      $DRY_RUN_CMD mv "$tmp_path" "$app_path"
    '');
}
