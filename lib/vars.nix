{ isDarwin }:
let usePantheon = false;
in {
  inherit usePantheon;
  useGnome = !usePantheon;
  copyCmd = if isDarwin then "pbcopy" else "xclip -selection clipboard";
  pasteCmd = if isDarwin then "pbpaste" else "xlip -o -selection clipboard";
}
