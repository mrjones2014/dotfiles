{ pkgs }:
pkgs.writeShellScriptBin "gh-1p" ''
  # pass through commands that don't need auth
  case "''${1:-}" in
    --help|-h|--version|help|version|__complete|"")
      exec ${pkgs.gh}/bin/gh "$@"
      ;;
  esac

  # default to personal token
  token="op://Private/GitHub/token"
  account_uuid="3UBYV6PWJZAS7HTEKHDSQ7HPUA"

  url="$(git config --get remote.origin.url 2>/dev/null || true)"
  if [[ "$url" == *"github.com:agilebits-inc"* ]]; then
    token="op://Employee/1Password GitHub Token/credential"
    account_uuid="AKHM3DPGNZFUJOY7N4UAWAMLIE"
  fi

  GITHUB_TOKEN="$(op read --account "$account_uuid" "$token")" \
    exec ${pkgs.gh}/bin/gh "$@"
''
