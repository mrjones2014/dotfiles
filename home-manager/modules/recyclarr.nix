{ pkgs, ... }: {
  home.packages = [
    pkgs.recyclarr
    (pkgs.writeScriptBin "recyclarr-sync" ''
      op inject -i ~/git/dotfiles/recyclarr.yml -o ~/git/dotfiles/recyclarr-tmp.yml \
        && recyclarr sync --config ~/git/dotfiles/recyclarr-tmp.yml \
        && rm ~/git/dotfiles/recyclarr-tmp.yml
    '')
  ];
}

