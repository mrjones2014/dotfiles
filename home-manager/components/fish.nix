{
  config,
  pkgs,
  lib,
  isDarwin,
  isLinux,
  ...
}:
{
  home.sessionVariables = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    HOMEBREW_NO_ANALYTICS = "1";
    CARGO_NET_GIT_FETCH_WITH_CLI = "true";
    GIT_MERGE_AUTOEDIT = "no";
    NEXT_TELEMETRY_DISABLED = "1";
  };
  programs = {
    btop.enable = true;
    carapace.enable = true;
    bat.enable = true;

    lsd = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        sorting.dir-grouping = "first";
        icons.when = "always";
        color.when = "always";
      };
    };
    fish = {
      enable = true;
      shellAliases = {
        ":q" = "exit";
        ":Q" = "exit";
        ":e" = "nvim";
        ":vsp" = "zellij action new-pane --direction right";
        ":sp" = "zellij action new-pane --direction down";

        copy = if isDarwin then "pbcopy" else "wl-copy";
        paste = if isDarwin then "pbpaste" else "wl-paste";
        cat = "bat";
        "!!" = "eval \\$history[1]";
        clear = "clear && _prompt_move_to_bottom";
        # inspect $PATH
        pinspect = ''echo "$PATH" | tr ":" "\n"'';

        sqlite3 = "litecli";
        sqlite = "litecli";
      };

      shellInit = /* fish */ ''
        # put Nix profile *first* on my PATH
        export PATH="/etc/profiles/per-user/${config.home.username}/bin:$PATH"
        set -g fish_prompt_pwd_dir_length 20
      '';

      interactiveShellInit = /* fish */ ''
        fish_vi_key_bindings
        bind -M insert jk "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

        # restore old ctrl+c behavior; it should not clear the line in case I want to copy it or something
        # the new default behavior is stupid and bad, it just clears the current prompt
        # https://github.com/fish-shell/fish-shell/issues/11327
        bind -M insert -m insert ctrl-c cancel-commandline

        set fish_cursor_default block
        set fish_cursor_insert block
        set fish_cursor_replace_one underscore
        set fish_cursor_visual block

        # I like to keep the prompt at the bottom rather than the top
        # of the terminal window so that running `clear` doesn't make
        # me move my eyes from the bottom back to the top of the screen;
        # keep the prompt consistently at the bottom
        _prompt_move_to_bottom # call function manually to load it since event handlers don't get autoloaded
      '';

      functions = {
        fish_greeting = "";
        _prompt_move_to_bottom = {
          onEvent = "fish_postexec";
          body = "tput cup $LINES";
        };
        spc = {
          description = "Print a separator to help visually separate long outputs.";
          body = /* fish */ ''
            echo
            echo
            string repeat -n (tput cols) '─'
            echo
            echo
          '';
        };
        groot = {
          description = "cd to the root of the current git repository";
          body = /* fish */ ''
            set -l git_repo_root_dir (git rev-parse --show-toplevel 2>/dev/null)
            if test -n "$git_repo_root_dir"
                cd "$git_repo_root_dir"
                echo -e ""
                echo -e "      \e[1m\e[38;5;112m\^V//"
                echo -e "      \e[38;5;184m|\e[37m· ·\e[38;5;184m|      \e[94mI AM GROOT !"
                echo -e "    \e[38;5;112m- \e[38;5;184m\ - /"
                echo -e "     \_| |_/\e[38;5;112m¯"
                echo -e "       \e[38;5;184m\ \\"
                echo -e "     \e[38;5;124m__\e[38;5;184m/\e[38;5;124m_\e[38;5;184m/\e[38;5;124m__"
                echo -e "    |_______|"
                echo -e "     \     /"
                echo -e "      \___/\e[39m\e[00m"
                echo -e ""
            else
                echo "Not in a git repository."
            end
          '';
        };
        nix-shell = {
          wraps = "nix-shell";
          body = /* fish */ ''
            for ARG in $argv
                if [ "$ARG" = --run ]
                    command nix-shell $argv
                    return $status
                end
            end
            command nix-shell $argv --run "exec fish"
          '';
        };
        mr = /* fish */ ''
          set -l GITLAB_BASE_URL "https://gitlab.1password.io"
          set -l PROJECT_PATH (git config --get remote.origin.url | sed 's/^ssh.*@[^/]*\(\/.*\).git/\1/g')
          set -l GIT_BRANCH (git branch --show-current)
          if test -z "$GIT_BRANCH"
              set GIT_BRANCH (jj --ignore-working-copy log -r @- --no-graph --no-pager -T 'self.bookmarks()')
          end
          if test -z "$GIT_BRANCH"
              echo "Error: not a git repo"
              return 1
          end
          set -l GITLAB_MR_URL "$GITLAB_BASE_URL$PROJECT_PATH/-/merge_requests/new?merge_request%5Bsource_branch%5D=$GIT_BRANCH"
          ${if isLinux then "xdg-open" else "open"} "$GITLAB_MR_URL"
        '';
        pr =
          let
            open = if isLinux then "xdg-open" else "open";
          in
          /* fish */ ''
            set -l GIT_BRANCH (git branch --show-current 2>/dev/null || echo "")

            if test -z "$GIT_BRANCH"
                set GIT_BRANCH (jj log -r @- --no-graph --no-pager -T 'self.bookmarks()')
            end

            if test -z "$GIT_BRANCH"
                echo "Error: not a git repository"
                return 1
            end

            set -l HAS_UPSTREAM (git config --get remote.upstream.url 2>/dev/null)

            if test -n "$HAS_UPSTREAM"
                set -l UPSTREAM_PATH (git config --get remote.upstream.url)
                set UPSTREAM_PATH (string replace "git@github.com:" "" "$UPSTREAM_PATH")
                set UPSTREAM_PATH (string replace "https://github.com/" "" "$UPSTREAM_PATH")
                set UPSTREAM_PATH (string replace ".git" "" "$UPSTREAM_PATH")

                set -l ORIGIN_PATH (git config --get remote.origin.url)
                set ORIGIN_PATH (string replace "git@github.com:" "" "$ORIGIN_PATH")
                set ORIGIN_PATH (string replace "https://github.com/" "" "$ORIGIN_PATH")
                set ORIGIN_PATH (string replace ".git" "" "$ORIGIN_PATH")

                set -l ORIGIN_OWNER (string split "/" "$ORIGIN_PATH")[1]
                set -l ORIGIN_REPO (string split "/" "$ORIGIN_PATH")[2]

                set -l MASTER_BRANCH (git symbolic-ref refs/remotes/upstream/HEAD | sed "s@^refs/remotes/upstream/@@")
                ${open} "https://github.com/$UPSTREAM_PATH/compare/$MASTER_BRANCH...$ORIGIN_OWNER:$ORIGIN_REPO:$GIT_BRANCH"
            else
                set -l PROJECT_PATH (git config --get remote.origin.url)
                set PROJECT_PATH (string replace "git@github.com:" "" "$PROJECT_PATH")
                set PROJECT_PATH (string replace "https://github.com/" "" "$PROJECT_PATH")
                set PROJECT_PATH (string replace ".git" "" "$PROJECT_PATH")

                set -l MASTER_BRANCH (git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@")
                ${open} "https://github.com/$PROJECT_PATH/compare/$MASTER_BRANCH...$GIT_BRANCH"
            end
          '';
      };
    };
  };

  home.packages =
    with pkgs;
    [
      litecli
      nix-output-monitor
      tealdeer
      tokei
      jq
      ripgrep
      gnused
      tree
    ]
    ++ lib.lists.optionals isLinux [ wl-clipboard ];

  xdg.configFile."litecli/config".text = with import ./tokyonight_palette.nix { inherit lib; }; ''
    [main]
    key_bindings = vi
    wider_completion_menu = True
    prompt = ' \d\n󰧚 '
    table_format = fancy_grid
    multi_line = True

    [colors]
    completion-menu.completion.current = 'bg:${fg} ${bg_dark}'
    completion-menu.completion = 'bg:${bg_highlight} ${fg}'
    completion-menu.meta.completion.current = 'bg:${blue} ${bg_dark}'
    completion-menu.meta.completion = 'bg:${fg_gutter} ${fg}'
    completion-menu.multi-column-meta = 'bg:${blue7} ${fg}'
    scrollbar.arrow = 'bg:${terminal_black}'
    scrollbar = 'bg:${dark3}'
    selected = '${bg_dark} bg:${blue}'
    search = '${fg} bg:${magenta}'
    search.current = '${bg_dark} bg:${green}'
    bottom-toolbar = 'bg:${bg} ${fg_dark}'
    bottom-toolbar.off = 'bg:${bg} ${comment}'
    bottom-toolbar.on = 'bg:${bg} ${fg}'
    search-toolbar = 'noinherit bold'
    search-toolbar.text = 'nobold'
    system-toolbar = 'noinherit bold'
    arg-toolbar = 'noinherit bold'
    arg-toolbar.text = 'nobold'
    bottom-toolbar.transaction.valid = 'bg:${bg} ${green} bold'
    bottom-toolbar.transaction.failed = 'bg:${bg} ${red} bold'
  '';
}
