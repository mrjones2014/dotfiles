{
  inputs,
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
  imports = [ inputs.jj-gh.homeManagerModules.default ];
  programs.jujutsu = {
    enable = true;
    gh = {
      enable = true;
      settings = {
        gh_askpass = [
          "op"
          "read"
          "op://Private/GitHub/token"
        ];
        editor = [
          "nvim"
          "+9"
        ];
      };
    };
    settings = {
      templates.git_push_bookmark = ''"mrj/push-" ++ change_id.short()'';
      git.private-commits = config.programs.jujutsu.settings.revset-aliases."private()";
      revsets.bookmark-advance-to = "@-";
      revset-aliases = {
        # The `trunk().. &` bit is an optimization to scan for non-`mine()` commits
        # only among commits that are not in `trunk()`
        # This prevents me from mutating any commit that isn't authored by me
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
        "private()" = ''description(glob:"wip:*") | description(glob:"private:*")'';
        # Returns the closest private commit to `to` (used for megamerge workflow)
        "closest_merge(to)" = "heads(::to & private() & mutable())";

      };
      aliases = {
        # megamerge aliases
        # takes a revset and rebases it between trunk() and the megamerge (makes it a parent of the megamerge)
        stack = [
          "rebase"
          "--after"
          "trunk()"
          "--before"
          "closest_merge(@)"
          "--revision"
        ];
        # rebase all mutable branch roots onto latest trunk (cascades up through megamerge automatically)
        restack = [
          "rebase"
          "--onto"
          "trunk()"
          "--source"
          "roots(trunk()..) & mutable()"
          "--simplify-parents"
        ];
        # like `stack` but automatically targets all non-empty commits above the megamerge
        stage = [
          "stack"
          "closest_merge(@)+:: ~ empty()"
        ];

        prs =
          let
            jq = "${pkgs.jq}/bin/jq";
            fzf = "${pkgs.fzf}/bin/fzf";
            esc = color: "\\e[38;2;${palette.hexToAnsiRgb color}m";
            cyan = esc palette.cyan;
            magenta = esc palette.magenta;
            yellow = esc palette.orange;
            green = esc palette.green;
            dim = esc palette.comment;
            reset = "\\e[0m";
          in
          [
            "util"
            "exec"
            "--"
            "bash"
            "-c"
            /* bash */ ''
              set -euo pipefail

              # fetch PRs and format them with jq
              prs=$(op plugin run -- gh pr list --json number,author,title,state,labels | ${jq} -r \
                --arg cyan $'${cyan}' \
                --arg magenta $'${magenta}' \
                --arg yellow $'${yellow}' \
                --arg green $'${green}' \
                --arg dim $'${dim}' \
                --arg reset $'${reset}' \
                '
                .[] |
                # format labels
                (.labels | map(.name) | if length > 0 then " " + $dim + "󰌕  " + $reset + $yellow + join($reset + " " + $yellow) + $reset else "" end) as $labels |
                # format the line
                "\($green) \($reset) \($cyan)#\(.number | tostring | . + " " * (5 - length))\($reset) \($magenta)\(.author.login | . + " " * ([16 - length, 1] | max))\($reset) \(.title)\($labels)"
              ')

              if [ -z "$prs" ]; then
                echo "No open PRs found."
                exit 0
              fi

              # run through fzf
              selected=$(echo -e "$prs" | ${fzf} --ansi --header=" PR     Author           Title" --reverse --height=50%)

              if [ -n "$selected" ]; then
                # extract PR number from selection
                pr_num=$(echo "$selected" | sed -n 's/.*#\([0-9]*\) .*/\1/p')
                if [ -n "$pr_num" ]; then
                  jj pr fetch "$pr_num"
                fi
              fi
            ''
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
