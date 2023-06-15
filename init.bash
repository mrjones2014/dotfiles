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

# only install `home-manager` this way if NOT on NixOS -- NixOS installs it as a NixOS module
if ! test -f "/etc/NIXOS" && ! command -v home-manager >/dev/null 2>&1; then
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
  echo "${SCRIPT_DIR/$HOME/~}/conf.d/setup-macos-defaults.bash"
  read -r -p "Proceed? (y/n): " input
  case "$input" in
  [yY] | [yY][eE][sS])
    "$SCRIPT_DIR/conf.d/setup-macos-defaults.bash"
    ;;
  *) ;;
  esac
elif ! command -v nixos-version >/dev/null 2>&1; then
  # if NOT on NixOS
  if ! test -f "/etc/NIXOS"; then
    # if on Linux but not NixOS, install nixGL
    echo "Installing nixGL"
    nix-channel --add https://github.com/guibou/nixGL/archive/main.tar.gz nixgl && nix-channel --update
    nix-env -iA nixgl.auto.nixGLDefault
  fi
fi

echo
echo "Everything should be set up. Run one of the following commands (depending on your current system) to apply configuration. After applied, you can use \`nix-apply\` (a shell alias) going forward."
echo

# output value of the shell alias, highlighted
grep "switch --flake" "$SCRIPT_DIR/home-manager/modules/fish.nix" | sed -e 's/\(.*\)/\x1b[38;5;166m\1\x1b[0m/' | awk '{$1:$1;print}'
echo
