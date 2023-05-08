# so that I can show a special indicator in starship
if [ "$IN_NIX_SHELL" != "" ]; then
  export IN_NIX_DEVELOP_SHELL=1
fi
# so that when I run `nix develop` I still get a fish shell
exec fish
