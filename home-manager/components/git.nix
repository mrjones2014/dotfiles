{
  pkgs,
  isDarwin,
  isLinux,
  isServer,
  ...
}:
let
  git-ch = pkgs.writeShellScriptBin "git-ch" ''
    if test "$#" -ne 0; then
      if [[ "$*" = "master" ]] || [[ "$*" = "main" ]]; then
        git checkout "$(git branch --format '%(refname:short)' --sort=-committerdate --list master main | head -n1)"
      else
        git checkout "$@"
      fi
    else
      git branch -a --format="%(refname:short)" | sed 's|origin/||g' | grep -v "HEAD" | grep -v "origin" | sort | uniq | ${pkgs.fzf}/bin/fzf | xargs git checkout
    fi
  '';
  repo-config = pkgs.writeShellScriptBin "repo-config" ''
    set -euo pipefail

    large_repo=false
    if [[ $# -gt 0 && "$1" == "--large" ]]; then
      large_repo=true
    fi

    url="$(git remote get-url origin)"
    if [[ "$url" == *"gitlab.1password.io"* ]]; then
      work_email="mat.jones@agilebits.com"
      work_signing_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAjOfOY+u3Ei+idMfwQ/KD/X1S+JNrsc7ffN/NY8kqX"

      git config --local user.email "$work_email"
      git config --local user.signingKey "$work_signing_key"
      jj config set --repo user.email "$work_email"
      jj config set --repo signing.key "$work_signing_key"
      echo "Updated repo-local configs to use work email and signing key"

      if [[ "$large_repo" == true ]]; then
        git config --local remote.origin.fetch "+refs/heads/main:refs/remotes/origin/main"
        git config --local --add remote.origin.fetch "+refs/heads/mrj/*:refs/remotes/origin/mrj/*"
        git config --local remote.origin.tagOpt "--no-tags"
        echo "Configured optimized refspec for large repository"
      fi
    else
      echo "Nothing to do"
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

    if [[ "$repo_name" == "dotfiles" ]]; then
      jj config set --repo experimental-advance-branches.enabled-branches "[\"glob:*\"]"
      jj config set --repo experimental-advance-branches.disabled-branches []
      jj bookmark track master@origin
    fi

    if [[ "$large_repo" == true ]]; then
      git init
      git remote add origin "$url"
      jj git init --colocate
      ${repo-config}/bin/repo-config
      git fetch
      jj new main
    else
      git clone "$url"
      cd "$repo_name"
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
  programs.git = {
    enable = true;
    package = pkgs.git.override {
      guiSupport = false; # gui? never heard of her.
    };
    ignores = [
      "Session.vim"
      ".DS_Store"
      ".direnv/"
    ];
    aliases = {
      s = "status";
      newbranch = "checkout -b";
      commit-amend = "commit --amend --no-edit";
      prune-branches = ''!git branch --merged | grep -v \"master\" | grep -v \"main\" | grep -v \"$(git branch --show-current)\" | grep -v "[*]" >/tmp/merged-branches && vim /tmp/merged-branches && xargs git branch -d </tmp/merged-branches && git fetch --prune'';
      ch = "!${git-ch}/bin/git-ch";
      mm = ''!git fetch && git merge "origin/$(git branch --format '%(refname:short)' --sort=-committerdate --list master main | head -n1)"'';
      add-ignore-whitespace = "!git diff --ignore-all-space | git apply --cached";
      copy-branch = "!git branch --show-current | ${
        if isDarwin then "pbcopy" else "xclip -selection clipboard"
      }";
      pending = "!git log $(git describe --tags --abbrev=0)..HEAD --oneline";
      # bc = "branch changes"
      bc = "!export MASTER_BRANCH=$(git branch -r | grep -Po 'HEAD -> \\K.*$') && git diff --name-only $MASTER_BRANCH | ${pkgs.fzf}/bin/fzf --ansi --preview 'git diff --color=always $MASTER_BRANCH {}' --bind 'enter:become($EDITOR {})'";
    };
    userName = "Mat Jones";
    userEmail = "mat@mjones.network";
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsT6GLG7sY8YKX7JM+jqS3EAti3YMzwHKWViveqkZvu";
      signByDefault = true;
    };
    delta = {
      enable = true;
      options = {
        line-numbers = true;
        navigate = true;
      };
    };
    extraConfig = {
      rerere.enabled = true;
      pull.rebase = false;
      push.autoSetupRemote = true;
      commit.gpgsign = true;
      gpg =
        {
          format = "ssh";
        }
        // pkgs.lib.optionalAttrs (!isServer) {
          ssh = {
            program =
              if isLinux then
                "/run/current-system/sw/bin/op-ssh-sign"
              else
                "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          };
        };
      core = {
        autocrlf = false;
        fsmonitor = true;
        untrackedcache = true;
      };
      init.defaultBranch = "master";
      color = {
        ui = true;
        "diff-highlight" = {
          oldNormal = "red bold";
          oldHighlight = "red bold 52";
          newNormal = "green bold";
          newHighlight = "green bold 22";
        };
        diff = {
          meta = "11";
          frag = "magenta bold";
          func = "146 bold";
          commit = "yellow bold";
          old = "red bold";
          new = "green bold";
          whitespace = "red reverse";
        };
      };
      fetch.prune = true;
      checkout.defaultRemote = "origin";
      # faster git server communications
      # https://git-scm.com/docs/protocol-v2
      protocol.version = 2;
      url = {
        "git@gitlab.1password.io:" = {
          insteadOf = "https://gitlab.1password.io/";
        };
        # Use HTTPS for cargo updates
        "https://github.com/rust-lang/crates.io-index" = {
          insteadOf = "https://github.com/rust-lang/crates.io-index";
        };
      };
    };
  };
}
