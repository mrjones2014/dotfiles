{ pkgs, agenix-rekey }:
pkgs.writeShellApplication {
  name = "agenix-edit";
  runtimeInputs = [ agenix-rekey ];
  text = ''
    if [[ $# -eq 1 && ( "$1" == --help || "$1" == -h ) ]]; then
      echo "Usage: agenix-edit NAME[.age] (or secrets/NAME.age)"
      exit 0
    fi
    if [[ $# -ne 1 ]]; then
      echo "Usage: agenix-edit NAME[.age] (or secrets/NAME.age)" >&2
      exit 1
    fi
    if [[ ! -t 0 ]]; then
      echo "agenix-edit requires an interactive terminal; refusing to replace a secret from stdin" >&2
      exit 1
    fi

    root="$PWD"
    while [[ ! -f "$root/flake.nix" || ! -f "$root/secrets/master.age" ]]; do
      if [[ "$root" == / ]]; then
        echo "Could not find the dotfiles flake and secrets/master.age in this directory or its parents" >&2
        exit 1
      fi
      root="$(dirname "$root")"
    done

    name="''${1#secrets/}"
    if [[ ! "$name" =~ ^[[:alnum:]_-]+(\.age)?$ ]]; then
      echo "Expected a secret name or secrets/NAME.age" >&2
      exit 1
    fi
    [[ "$name" == *.age ]] || name="$name.age"
    cd "$root"
    exec agenix edit "secrets/$name"
  '';
}
