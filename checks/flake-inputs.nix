{ pkgs }:
pkgs.runCommand "nix-flake-inputs" { nativeBuildInputs = [ pkgs.jaq ]; } ''
  dupes=$(jaq -r '.nodes | keys[] | select(test("_[0-9]+$"))' ${../flake.lock})
  if [ -n "$dupes" ]; then
    echo "Duplicate flake.lock inputs detected (add an explicit"
    echo "inputs.<name>.follows in flake.nix for each):"
    echo "$dupes"
    exit 1
  fi
  touch $out
''
