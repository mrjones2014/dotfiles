{
  pkgs,
  lib,
  isLinux,
  ...
}:
{
  home.packages = lib.lists.optionals isLinux [
    pkgs.recyclarr
    (pkgs.writeShellScriptBin "recyclarr-sync" ''
      op inject -i ~/git/dotfiles/home-manager/components/recyclarr.yaml -o ~/git/dotfiles/recyclarr-tmp.yml \
        && recyclarr sync --config ~/git/dotfiles/recyclarr-tmp.yml
      rm -f ~/git/dotfiles/recyclarr-tmp.yml
    '')
  ];
}
