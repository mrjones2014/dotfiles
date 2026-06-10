{ pkgs }:
pkgs.writeShellScriptBin "gh" ''
  url="$(git config --get remote.origin.url 2>/dev/null || true)"
  if [[ "$url" == *"github.com:agilebits-inc"* ]]; then
    # work uses OAuth tokens now, `gh auth login`
    exec ${pkgs.gh}/bin/gh "$@"
  fi

  # pass through commands that don't need auth
  case "''${1:-}" in
    --help|-h|--version|help|version|__complete|"")
      exec ${pkgs.gh}/bin/gh "$@"
      ;;
  esac

  # else use personal token
  token="op://Private/GitHub/token"
  account_uuid="3UBYV6PWJZAS7HTEKHDSQ7HPUA"
  GITHUB_TOKEN="$(op read --account "$account_uuid" "$token")" \
    exec ${pkgs.gh}/bin/gh "$@"
''
