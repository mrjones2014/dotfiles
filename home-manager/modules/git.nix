{ pkgs, isDarwin, isLinux, isServer, ... }:
let
  git_checkout_fzf_script = pkgs.writeScript "git-ch.bash" ''
    #!${pkgs.bash}/bin/bash
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
in {
  programs.git = {
    enable = true;
    package = pkgs.git.override {
      guiSupport = false; # gui? never heard of her.
    };
    ignores = [ "Session.vim" ".DS_Store" ".direnv/" ];
    aliases = {
      s = "status";
      newbranch = "checkout -b";
      commit-amend = "commit --amend --no-edit";
      prune-branches = ''
        !git branch --merged | grep -v \"master\" | grep -v \"main\" | grep -v \"$(git branch --show-current)\" | grep -v "[*]" >/tmp/merged-branches && vim /tmp/merged-branches && xargs git branch -d </tmp/merged-branches && git fetch --prune'';
      ch = "!${git_checkout_fzf_script}";
      mm = ''
        !git fetch && git merge "origin/$(git branch --format '%(refname:short)' --sort=-committerdate --list master main | head -n1)"'';
      add-ignore-whitespace =
        "!git diff --ignore-all-space | git apply --cached";
      copy-branch = "!git branch --show-current | ${
          if isDarwin then "pbcopy" else "xclip -selection clipboard"
        }";
      pending = "!git log $(git describe --tags --abbrev=0)..HEAD --oneline";
      # bc = "branch changes"
      bc =
        "!export MASTER_BRANCH=$(git branch -r | grep -Po 'HEAD -> \\K.*$') && git diff --name-only $MASTER_BRANCH | ${pkgs.fzf}/bin/fzf --ansi --preview 'git diff --color=always $MASTER_BRANCH {}' --bind 'enter:become($EDITOR {})'";
    };
    userName = "Mat Jones";
    userEmail = "mat@mjones.network";
    signing = {
      key =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsT6GLG7sY8YKX7JM+jqS3EAti3YMzwHKWViveqkZvu";
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
      gpg = {
        format = "ssh";
      } // pkgs.lib.optionalAttrs (!isServer) {
        ssh = {
          program = if isLinux then
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
