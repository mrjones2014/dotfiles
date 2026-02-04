{
  config,
  pkgs,
  lib,
  isServer,
  ...
}:
let
  palette = import ../tokyonight_palette.nix { inherit lib; };
in
{
  programs.jujutsu = {
    enable = true;
    settings = {
      templates.git_push_bookmark = ''"mrj/push-" ++ change_id.short()'';
      git.private-commits = lib.mkDefault "description(glob:'wip:*') | description(glob:'private:*')";
      experimental-advance-branches = {
        enabled-branches = [ "glob:*" ];
        disabled-branches = [
          "master"
          "main"
        ];
      };
      revset-aliases = lib.mkDefault {
        # The `trunk().. &` bit is an optimization to scan for non-`mine()` commits
        # only among commits that are not in `trunk()`
        # This prevents me from mutating any commit that isn't authored by me
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
      };
      colors = {
        # lighten these up a bit for statusline integration
        "change_id rest" = palette.dark3;
        "commit_id rest" = palette.dark3;
      };
      aliases = {
        # https://shaddy.dev/notes/jj-tug/
        tug = [
          "bookmark"
          "move"
          "--from"
          "heads(::@- & (bookmarks() ~ trunk()))"
          "--to"
          "@-"
        ];
        pr = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            set -euo pipefail

            if [ ! -d .git ]; then
              echo "Error: this relies on a colocated git repository; jj doesn't yet support fetching non-head refs" >&2
              exit 1
            fi

            if [ -z "''${1:-}" ]; then
              echo "Usage: jj pr <pr-number>" >&2
              exit 1
            fi

            pr_num="$1"
            branch_name="pr-$pr_num"

            # jj does not yet have the ability to fetch arbitrary
            # refs (it always fetches from `refs/head/*`) but we
            # can rely on git for that part and do the rest in jj
            echo "Fetching PR #$pr_num..."
            git fetch origin "refs/pull/$pr_num/head:refs/heads/$branch_name" --force

            # import the git ref into jj and checkout
            jj git import
            jj new "$branch_name"

            # clean up old pr-* branches
            for branch in $(git branch --list 'pr-*' --format='%(refname:short)'); do
              if [ "$branch" = "$branch_name" ]; then
                continue
              fi
              jj abandon "$branch" 2>/dev/null || true
              git branch -D "$branch" 2>/dev/null || true
            done
            jj git import
          ''
          ""
        ];
        sync = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            set -euo pipefail

            # Detect which trunk branch exists (master or main)
            if jj --ignore-working-copy bookmark list -r 'master@origin' &>/dev/null; then
              trunk="master"
            elif jj --ignore-working-copy bookmark list -r 'main@origin' &>/dev/null; then
              trunk="main"
            else
              echo "Error: Could not detect trunk branch (master or main)" >&2
              exit 1
            fi

            # Get the bookmark at @-
            parent_bookmark=$(jj --ignore-working-copy bookmark list -r @- --no-pager -T 'self.name() ++ "\n"' 2>/dev/null | head -n 1)

            if [ -n "''${1:-}" ]; then
              # fetch and rebase $1
              echo "Fetching $1@origin..."
              jj git fetch -b "$1" && jj rebase -d "$1@origin"
            elif [ "$parent_bookmark" = "master" ] || [ "$parent_bookmark" = "main" ]; then
              # fetch and rebase to bookmark
              echo "Fetching $parent_bookmark@origin..."
              jj git fetch -b "$parent_bookmark" && jj rebase -d "$parent_bookmark@origin"
            else
              # fetch and rebase to trunk
              echo "Fetching $trunk@origin..."
              jj git fetch -b "$trunk" && jj rebase -d "$trunk@origin"
            fi
          ''
          # From jj docs:
          # > This last empty string will become "$0" in bash, so your actual arguments
          # > are all included in "$@" and start at "$1" as expected.
          # https://docs.jj-vcs.dev/latest/config/#aliases
          ""
        ];
      };
      # https://github.com/jj-vcs/jj/discussions/4690#discussioncomment-13902914
      diff.tool = "${pkgs.delta}/bin/delta";
      ui = {
        diff-formatter = ":git";
        pager = [
          "delta"
          "--pager"
          "less -FRX"
        ];
      };
      scope = [
        {
          "--when.commands" = [
            "diff"
            "show"
          ];
        }
      ];
      "--scope.ui".pager = "delta";
      user = {
        inherit (config.programs.git.settings.user) name;
        inherit (config.programs.git.settings.user) email;
      };
      signing = {
        inherit (config.programs.git.signing) key;
        behavior = "force";
        backend = "ssh";
      }
      // lib.optionalAttrs (!isServer) {
        backends.ssh.program = config.programs.git.settings.gpg.ssh.program;
      };
    };
  };
}
