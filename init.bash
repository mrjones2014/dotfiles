#!/usr/bin/env bash

set -eu pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix is not installed. Running Nix installation..."
  if [ "$(uname -s)" == "Darwin" ]; then
    sh <(curl -L https://nixos.org/nix/install)
  else
    sh <(curl -L https://nixos.org/nix/install) --daemon
  fi

  echo
  echo "Nix installed successfully. Restart your shell, then run this script again."
  echo
  exit 0 # must restart shell before continuing
fi

if ! command -v home-manager >/dev/null 2>&1; then
  echo "home-manager not installed. Running home-manager installation..."
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  nix-shell '<home-manager>' -A install
  echo
  echo "home-manager installed successfully."
  echo
fi

if [ "$(uname -s)" == "Darwin" ]; then
  defaults write org.hammerspoon.Hammerspoon MJConfigFile "${XDG_CONFIG_HOME:-$HOME/.config}/hammerspoon/init.lua"
  echo "On macOS I can also set many OS settings to more sane defaults."
  echo "This will run the following script, you should inspect the contents first if you're not familiar with it:"
  echo "${SCRIPT_DIR/$HOME/~}/scripts/setup-macos-defaults.bash"
  read -r -p "Proceed? (y/n): " input
  case "$input" in
  [yY] | [yY][eE][sS])
    "$SCRIPT_DIR/scripts/setup-macos-defaults.bash"
    ;;
  *) ;;
  esac
fi

echo
echo "Everything should be set up. Run the following command to apply configuration. After applied, you can use \`nix-apply\` (a shell alias) going forward."
echo

if [ "$(uname -s)" == "Darwin" ]; then
  echo 'NIX_CONFIG="experimental-features = nix-command flakes" home-manager switch --flake ~/git/dotfiles/.#mac' | sed -e 's/\(.*\)/\x1b[38;5;166m\1\x1b[0m/'
else
  echo 'NIX_CONFIG="experimental-features = nix-command flakes" home-manager switch --flake ~/git/dotfiles/.#linux' | sed -e 's/\(.*\)/\x1b[38;5;166m\1\x1b[0m/'
fi
echo
