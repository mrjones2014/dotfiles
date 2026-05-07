{
  config,
  pkgs,
  lib,
  isDarwin,
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

        pr =
          let
            yq = "${pkgs.yq-go}/bin/yq";
            open = if isDarwin then "open" else "xdg-open";
            copy = if isDarwin then "pbcopy" else "wl-copy";
          in
          [
            "util"
            "exec"
            "--"
            "bash"
            "-c"
            /* bash */ ''
              set -euo pipefail

              use_editor=0
              rev=""
              for a in "$@"; do
                case "$a" in
                  -e) use_editor=1 ;;
                  -*) echo "Unknown flag: $a" >&2; exit 2 ;;
                  *)
                    if [ -z "$rev" ]; then
                      rev="$a"
                    else
                      echo "Usage: jj pr [-e] <rev>" >&2
                      exit 2
                    fi
                    ;;
                esac
              done
              if [ -z "$rev" ]; then
                echo "Usage: jj pr [-e] <rev>" >&2
                exit 2
              fi

              get_branch() {
                jj --ignore-working-copy log -r "$rev" --no-graph --no-pager \
                  -T 'self.bookmarks()' | awk '{print $1}'
              }
              rev_commit=$(jj --ignore-working-copy log -r "$rev" --no-graph --no-pager -T 'commit_id')

              branch=$(get_branch)
              needs_push=1
              if [ -n "$branch" ]; then
                remote_commit=$(git rev-parse "refs/remotes/origin/$branch" 2>/dev/null || true)
                if [ "$rev_commit" = "$remote_commit" ]; then
                  needs_push=0
                  echo "Already pushed: $branch"
                fi
              fi

              if [ "$needs_push" -eq 1 ]; then
                jj git push -c "$rev"
                branch=$(get_branch)
              fi
              if [ -z "$branch" ]; then
                echo "Error: no bookmark found on $rev" >&2
                exit 1
              fi

              default_branch=main
              if git show-ref --verify --quiet refs/remotes/origin/master 2>/dev/null; then
                default_branch=master
              fi

              parse_path() {
                echo "$1" | sed -E 's#^git@github\.com:##; s#^https://github\.com/##; s#\.git$##'
              }
              origin_path=$(parse_path "$(git config --get remote.origin.url)")
              upstream_url=$(git config --get remote.upstream.url 2>/dev/null || true)

              if [ -n "$upstream_url" ]; then
                upstream_path=$(parse_path "$upstream_url")
                target_repo="$upstream_path"
                origin_owner="''${origin_path%%/*}"
                origin_repo="''${origin_path##*/}"
                head_spec="$origin_owner:$branch"
                compare_url="https://github.com/$upstream_path/compare/$default_branch...$origin_owner:$origin_repo:$branch"
              else
                target_repo="$origin_path"
                head_spec="$branch"
                compare_url="https://github.com/$origin_path/compare/$default_branch...$branch"
              fi

              if [ "$use_editor" -eq 0 ]; then
                ${open} "$compare_url"
                exit 0
              fi

              default_title=$(jj --ignore-working-copy log -r "roots(trunk()..($rev))" \
                --no-graph --no-pager -T 'description.first_line()' | head -n1)

              tmpfile=$(mktemp "''${TMPDIR:-/tmp}/jj-pr.XXXXXXXX.md")
              trap 'rm -f "$tmpfile"' EXIT

              escaped_title=$(printf '%s' "$default_title" | sed 's/\\/\\\\/g; s/"/\\"/g')
              {
                echo '---'
                echo "title: \"$escaped_title\""
                echo 'labels: []'
                echo '---'
                echo
                echo
              } > "$tmpfile"

              "''${EDITOR:-nvim}" + "$tmpfile"

              title=$(${yq} --front-matter=extract '.title // ""' "$tmpfile")
              labels=$(${yq} --front-matter=extract '.labels // [] | join(",")' "$tmpfile")
              body=$(awk 'BEGIN{n=0} n<2 && /^---$/{n++; next} n>=2{print}' "$tmpfile")

              if [ -z "$title" ] || [ "$title" = "null" ]; then
                echo "Error: empty title; aborting" >&2
                exit 1
              fi

              gh_args=(pr create -R "$target_repo" -H "$head_spec" -B "$default_branch" \
                --title "$title" --body "$body")
              if [ -n "$labels" ]; then
                gh_args+=(--label "$labels")
              fi

              url=$(gh "''${gh_args[@]}")
              echo "$url"
              printf '%s' "$url" | ${copy}
            ''
            ""
          ];

        checkout-pr = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          /* bash */ ''
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
                  jj pr "$pr_num"
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
