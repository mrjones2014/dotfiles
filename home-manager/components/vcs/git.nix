{
  pkgs,
  isServer,
  isLinux,
  ...
}:
{
  programs = {
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        line-numbers = true;
        navigate = true;
      };
    };
    git = {
      enable = true;
      package = pkgs.git.override {
        guiSupport = false; # gui? never heard of her.
      };
      ignores = [
        "Session.vim"
        ".DS_Store"
        ".direnv/"
      ];
      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsT6GLG7sY8YKX7JM+jqS3EAti3YMzwHKWViveqkZvu";
        signByDefault = true;
      };
      settings = {
        user = {
          name = "Mat Jones";
          email = "mat@mjones.network";
        };
        alias.pending = "!git log $(git describe --tags --abbrev=0)..HEAD --oneline";
        rerere.enabled = true;
        pull.rebase = false;
        push.autoSetupRemote = true;
        commit.gpgsign = true;
        gpg = {
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
  };
}
