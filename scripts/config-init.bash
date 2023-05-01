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

sh <(curl -L https://nixos.org/nix/install) --daemon

echo "Installed Nix package manager. Restart shell, then run the following commands:"
echo "  \$ nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager"
echo "  \$ nix-channel --update"
echo "  \$ nix-shell '<home-manager>' -A install"
echo "Then, restart shell again and run:"
echo "  \$ home-manager switch"

echo "If setting up a mac, you should also run ~/scripts/setup-macos-defaults.bash"
