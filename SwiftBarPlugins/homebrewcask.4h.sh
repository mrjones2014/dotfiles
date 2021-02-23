#!/usr/bin/env bash

# Slightly customized version of
# https://github.com/matryer/bitbar-plugins/blob/master/Dev/Homebrew/homebrewcask.1d.sh

exit_with_error() {
  echo "err | color=red";
  exit 1;
}

/usr/local/bin/brew update &> /dev/null || exit_with_error;

HAS_UPDATES=$(brew outdated);

if [[ "$HAS_UPDATES" ]]; then
  echo "Brew: Ugrades Available";
  echo "---";
else
  echo "Brew";
  echo "---";
  echo "All packages up-to-date."
fi;

echo "Brew Update | bash=brew param1=update terminal=true refresh=true"
echo "Brew Upgrade | bash=brew param1=upgrade terminal=true refresh=true"
echo "Brew Cleanup | bash=brew param1=cleanup terminal=true refresh=true"
echo "Brew Cask Cleanup | bash=brew param1=cask param2=cleanup terminal=true refresh=true"
