#!/usr/bin/env bash

set -eu pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
mkdir -p "$SCRIPT_DIR/local"
touch "$SCRIPT_DIR/local/gitconfig.local"

function syntax_highlight_toml() {
  if [ $# -ne 1 ]; then
    echo "Error: Function requires exactly one argument"
    return 1
  fi

  TOML="$1"
  printf "%s\n" "$TOML" | sed -E \
    -e 's/(\[.*\])/\\033[0;34m\1\\033[0m/g' \
    -e 's/^ +([^ ]+) *=/  \\033[0;32m\1 =\\033[0m/g' \
    -e 's/".*"/\\033[0;32m&\\033[0m/g'
}

function populate_gitconfig() {
  if [ $# -ne 1 ]; then
    echo "Error: Function requires exactly one argument"
    return 1
  fi

  if [ ! -f "$1" ]; then
    echo "Error: Argument is not a valid file path"
    return 1
  fi

  FILEPATH="$1"
  SHORTENED="${FILEPATH/$HOME/~}"
  echo -n "Enter email address to use for $SHORTENED: "
  read -r email_address
  if [ -z "$email_address" ]; then
    echo "Error: email address is required."
    return 1
  fi

  echo -n "Enter SSH public key (copy from 1Password) for $SHORTENED: "
  read -r signing_key
  if [ -z "$signing_key" ]; then
    echo "Error: signing key is required."
    return 1
  fi

  cat <<EOF >"$FILEPATH"
[user]
  email = "$email_address"
  signingKey = "$signing_key"
EOF

  echo -e "Wrote file $SHORTENED with contents: \n\n$(syntax_highlight_toml "$(cat "$FILEPATH")")\n\n"
  echo
}

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

GITHUB_GITCONFIG="$SCRIPT_DIR/local/gitconfig.github"
if [ ! -e "$GITHUB_GITCONFIG" ] || [ "$(cat "$GITHUB_GITCONFIG")" == "" ]; then
  touch "$GITHUB_GITCONFIG"
  populate_gitconfig "$GITHUB_GITCONFIG"
fi

GITLAB_GITCONFIG="$SCRIPT_DIR/local/gitconfig.gitlab"
if [ ! -e "$GITLAB_GITCONFIG" ] || [ "$(cat "$GITLAB_GITCONFIG")" == "" ]; then
  touch "$GITLAB_GITCONFIG"
  populate_gitconfig "$GITLAB_GITCONFIG"
fi

echo "If you need any local git config that applies to all remotes, place that in ${SCRIPT_DIR/$HOME/~}/local/gitconfig.local"
echo

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
