#!/usr/bin/env bash

git clone --bare git@github.com:mrjones2014/dotfiles.git $HOME/.dotfiles
function dots {
  git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}
mkdir -p .dotfiles-backup
dots checkout
if [ $? = 0 ]; then
  echo "Checked out dotfiles from git@github.com:mrjones2014/dotfiles.git"
else
  echo "Moving existing dotfiles to ~/.dotfiles-backup"
  dots checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
fi
dots checkout
dots config status.showUntrackedFiles no
dots config core.fsmonitor false
dots config core.untrackedcache false
