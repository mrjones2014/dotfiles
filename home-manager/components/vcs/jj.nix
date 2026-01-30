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
        sync = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            set -euo pipefail

            bookmarks=$(jj --ignore-working-copy bookmark list -r @- --no-pager -T 'self.name() ++ "\n"' | head -n 1)
            count=$(echo "$bookmarks" | wc -l)

            if [ "$count" -eq 0 ]; then
              echo "Error: No bookmark at @-" >&2
              exit 1
            fi

            if [ -n "''${1:-}" ]; then
              echo "Fetching $1@origin..."
              jj git fetch -b "$1" && jj rebase -d "$1@origin"
            else
              echo "Fetching $bookmarks@origin..."
              jj git fetch -b "$bookmarks" && jj rebase -d "$bookmarks@origin"
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
