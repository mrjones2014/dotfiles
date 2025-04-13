{ pkgs
, isDarwin
, ...
}:
let
  copy = "${(pkgs.writeShellScriptBin "copy" ''
  export DISPLAY=":0"
  echo "$@" | tr -d '\n' | ${if isDarwin then "pbcopy" else "${pkgs.xclip}/bin/xclip -selection clipboard"}
'')}/bin/copy";
in
pkgs.writeShellScriptBin "cmdp" ''
  declare -A commands=(
    ["  SSH to nixos-server"]="ssh_nixos_server"
  )

  if [ -d ".git" ]; then
    commands["󰊢  Copy git branch"]="copy_git_branch"
  fi

  run_detached() {
      ${pkgs.coreutils}/bin/nohup "$@" </dev/null >/dev/null 2>&1 &
      disown
  }

  ssh_nixos_server() {
     run_detached ghostty -e ssh mat@nixos-server
  }

  copy_git_branch() {
    local branch=$(git branch --show-current)
    if [ -z "$branch" ]; then
      echo "Could not get git branch"
      exit 1
    fi
    run_detached ${copy} "$branch"
  }

  selected=$(printf "%s\n" "''${!commands[@]}" | fzf)

  if [[ -n "$selected" ]]; then
      "''${commands[$selected]}"
  fi
''
