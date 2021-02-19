#!/usr/bin/env bash

# Slightly customized version of
# https://github.com/matryer/bitbar-plugins/blob/master/Dev/Homebrew/homebrewcask.1d.sh

exit_with_error() {
  echo "err | color=red";
  exit 1;
}

/usr/local/bin/brew update &> /dev/null || exit_with_error; 

brewcasklist=$(/usr/local/bin/brew cask ls -1 | sed 's_(!)__g' | xargs /usr/local/bin/brew cask info | grep -A 1 'Not installed' | sed -e 's_Not installed__g' -e 's_From: https://github\.com/caskroom/homebrew-cask/blob/master/Casks/__g' -e 's_\.rb__g');

brewcasknum=$(for line in $brewcasklist; do echo "$line" | grep "[a-z]" ; done | wc -w | xargs);

echo "Brew Updates: ${brewcasknum}"
echo "---"

if [[ "${brewcasknum}" != "0" ]]; then
    for line in $brewcasklist; do 
        echo "$line" | grep "[a-z]" | sed 's_\(.*\)_& | bash=brew param1=cask param2=install param3=& terminal=true refresh=_g';
    done
else
    echo "No updates available."
fi

echo "Brew Update | bash=brew param1=update terminal=true refresh="
echo "Brew Upgrade | bash=brew param1=upgrade terminal=true refresh="
echo "Brew Cleanup | bash=brew param1=cleanup terminal=true refresh="
echo "Brew Cask Cleanup | bash=brew param1=cask param2=cleanup terminal=true refresh="
