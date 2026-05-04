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
        pr = /* fish */ ''
          function __pr_parse_gh_path
              set -l url $argv[1]
              string replace -r '^git@github\.com:' "" $url | string replace -r '^https://github\.com/' "" | string replace -r '\.git$' ""
          end

          set -l branch (git branch --show-current 2>/dev/null)
          if test -z "$branch"
              set -l rev (if set -q argv[1]; echo $argv[1]; else; echo '@-'; end)
              set branch (jj --ignore-working-copy log -r $rev --no-graph --no-pager -T 'self.bookmarks()')
          end
          if test -z "$branch"
              echo "Error: no bookmark or branch found for current HEAD"
              return 1
          end

          set -l default_branch main
          if git show-ref --verify --quiet refs/remotes/origin/master 2>/dev/null
              set default_branch master
          end

          set -l upstream_url (git config --get remote.upstream.url 2>/dev/null)
          if test -n "$upstream_url"
              set -l upstream_path (__pr_parse_gh_path $upstream_url)
              set -l origin_path (__pr_parse_gh_path (git config --get remote.origin.url))
              set -l origin_owner (string split "/" $origin_path)[1]
              set -l origin_repo (string split "/" $origin_path)[2]
              ${
                if isLinux then "xdg-open" else "open"
              } "https://github.com/$upstream_path/compare/$default_branch...$origin_owner:$origin_repo:$branch"
          else
              set -l project_path (__pr_parse_gh_path (git config --get remote.origin.url))
              ${
                if isLinux then "xdg-open" else "open"
              } "https://github.com/$project_path/compare/$default_branch...$branch"
          end
        '';
      };
    };
  };

  home.packages =
    with pkgs;
    [
      nix-output-monitor
      tealdeer
      tokei
      jq
      ripgrep
      gnused
      tree
    ]
    ++ lib.lists.optionals isLinux [ wl-clipboard ];
}
