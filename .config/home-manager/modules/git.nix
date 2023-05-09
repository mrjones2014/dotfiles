{ pkgs, ... }:
let
  inherit (pkgs) git stdenv;
  inherit (stdenv) isLinux;
in {
  home.packages = [ pkgs.delta ];
  programs.git = {
    enable = true;
    package = git.override {
      guiSupport = false; # gui? never heard of her.
    };
    ignores = [
      "Session.vim"
      "packer_compiled.lua"
      ".DS_Store"
      "wget-log"
      "wget-log.*"
    ];
    aliases = {
      s = "status";
      newbranch = "checkout -b";
      commit-amend = "commit -a --amend --no-edit";
      prune-branches = ''
        !git branch --merged | grep -v \"master\" | grep -v \"main\" | grep -v \"$(git branch --show-current)\" | grep -v "[*]" >/tmp/merged-branches && vim /tmp/merged-branches && xargs git branch -d </tmp/merged-branches && git fetch --prune'';
      ch = "!$HOME/scripts/git-ch.bash";
      add-ignore-whitespace =
        "!git diff --ignore-all-space | git apply --cached";
      copy-branch = "!git branch --show-current | pbcopy";
      pending = "!git log $(git describe --tags --abbrev=0)..HEAD --oneline";
    };
    includes = [
      {
        condition = "hasconfig:remote.*.url:https://github.com/**";
        path = ~/.config/git/gitconfig.github;
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:*/**";
        path = ~/.config/git/gitconfig.github;
      }
      {
        condition = "hasconfig:remote.*.url:ssh://git@github.com:*/**";
        path = ~/.config/git/gitconfig.github;
      }
      {
        condition = "hasconfig:remote.*.url:ssh://git@ssh.gitlab.*.*:*/**";
        path = ~/.config/git/gitconfig.gitlab;
      }
    ];
    extraConfig = {
      user = { name = "Mat Jones"; };
      pull = { rebase = false; };
      push = { autoSetupRemote = true; };
      commit = { gpgsign = true; };
      gpg = {
        format = "ssh";
        ssh = {
          program = if isLinux then
            "/opt/1Password/op-ssh-sign"
          else
            "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };
      };
      core = {
        autocrlf = false;
        pager = "delta";
        fsmonitor = true;
        untrackedcache = true;
      };
      interactive = { diffFilter = "delta --color-only"; };
      init = { defaultBranch = "master"; };
      delta = {
        lineNumbers = true;
        navigate = true;
      };
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
      fetch = { prune = true; };
      checkout = { defaultRemote = "origin"; };
      # faster git server communications
      # https://git-scm.com/docs/protocol-v2
      protocol = { version = 2; };
      url = {
        # Force GitHub to use SSH
        "git@github.com:" = { insteadOf = "https://github.com/"; };
        # Use HTTPS for cargo updates
        "https://github.com/rust-lang/crates.io-index" = {
          insteadOf = "https://github.com/rust-lang/crates.io-index";
        };
      };
    };
  };
}
