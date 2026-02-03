{ pkgs, ... }:
let
  repo-config = pkgs.writeShellScriptBin "repo-config" ''
    set -euo pipefail

    large_repo=false
    if [[ $# -gt 0 && "$1" == "--large" ]]; then
      large_repo=true
    fi

    url="$(git remote get-url origin)"

    repo_name="$(basename "$(pwd)")"
    if [[ "$repo_name" == "dotfiles" ]]; then
      jj config set --repo experimental-advance-branches.enabled-branches "[\"glob:*\"]"
      jj config set --repo experimental-advance-branches.disabled-branches []
      jj bookmark track master@origin
    fi

    if [[ "$large_repo" == true ]]; then
      git config --local remote.origin.fetch "+refs/heads/main:refs/remotes/origin/main"
      git config --local --add remote.origin.fetch "+refs/heads/mrj/*:refs/remotes/origin/mrj/*"
      git config --local remote.origin.tagOpt "--no-tags"
      echo "Configured optimized refspec for large repository"
    fi

    if [[ "$url" == *"gitlab.1password.io"* ]] || [[ "$url" == *"github.com:agilebits"* ]] || [[ "$url" == *"github-enterprise:agilebits"* ]]; then
      work_email="mat.jones@agilebits.com"
      work_signing_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAjOfOY+u3Ei+idMfwQ/KD/X1S+JNrsc7ffN/NY8kqX"

      git config --local user.email "$work_email"
      git config --local user.signingKey "$work_signing_key"
      jj config set --repo user.email "$work_email"
      jj config set --repo signing.key "$work_signing_key"
      # we just changed the author config and I configure jj to configure non-mine commits as immutable
      jj describe --reset-author --no-edit -r @ --ignore-immutable
      echo "Updated repo-local configs to use work email and signing key"
    fi
  '';

  clone = pkgs.writeShellScriptBin "clone" ''
    set -euo pipefail

    if [[ $# -eq 0 ]]; then
      echo "Usage: clone [--large] <git-url>"
      echo "    --large will configure optimized refspec before cloning"
      exit 1
    fi

    large_repo=false
    url=""

    while [[ $# -gt 0 ]]; do
      case $1 in
        --large)
          large_repo=true
          shift
          ;;
        *)
          if [[ -z "$url" ]]; then
            url="$1"
          else
            echo "Error: Multiple URLs provided"
            exit 1
          fi
          shift
          ;;
      esac
    done

    [[ "$url" == git@*:* || "$url" == ssh://git@* ]] || {
      echo "Error: Not an SSH git URL format"
      exit 1
    }

    repo_name="$(basename "$url" .git)"
    repo_path="$HOME/git/$repo_name"
    if [[ -d "$repo_path" ]]; then
      echo "Error: Directory $repo_name already exists"
      exit 1
    fi
    mkdir -p "$repo_path"
    cd "$repo_path"
    echo "Setting up repository in ~/git/$repo_name"

    if [[ "$large_repo" == true ]]; then
      git init
      git remote add origin "$url"
      jj git init --colocate
      ${repo-config}/bin/repo-config --large
      git fetch
      jj bookmark track main@origin
      jj new main
    else
      git clone "$url" "$repo_path"
      cd "$repo_path"
      jj git init --colocate
      ${repo-config}/bin/repo-config
    fi
  '';
in
{
  home.packages = [
    repo-config
    clone
  ];
}
