{ pkgs, config, ... }:
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
      ch = "!${../../conf.d/git-ch.bash}";
      add-ignore-whitespace =
        "!git diff --ignore-all-space | git apply --cached";
      copy-branch = "!git branch --show-current | pbcopy";
      pending = "!git log $(git describe --tags --abbrev=0)..HEAD --oneline";
    };
    extraConfig = {
      user = {
        name = "Mat Jones";
        email = "mat@mjones.network";
        signingKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsT6GLG7sY8YKX7JM+jqS3EAti3YMzwHKWViveqkZvu";
      };
      pull = { rebase = false; };
      push = { autoSetupRemote = true; };
      commit = { gpgsign = true; };
      gpg = {
        format = "ssh";
        ssh = {
          program = if isLinux then
            "/run/current-system/sw/bin/op-ssh-sign"
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
