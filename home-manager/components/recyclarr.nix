{ pkgs, ... }:
{
  home.packages = [
    pkgs.recyclarr
    (pkgs.writeScriptBin "recyclarr-sync" ''
      op inject -i ~/git/dotfiles/conf.d/recyclarr.yml -o ~/git/dotfiles/recyclarr-tmp.yml \
        && recyclarr sync --config ~/git/dotfiles/recyclarr-tmp.yml
      rm -f ~/git/dotfiles/recyclarr-tmp.yml
    '')
  ];
}
