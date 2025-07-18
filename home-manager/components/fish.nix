{
  pkgs,
  lib,
  isDarwin,
  isLinux,
  ...
}:
let
  rebuild-cmd = if isDarwin then "darwin-rebuild" else "nixos-rebuild";
  rebuild-script = ''
    sudo echo
    sudo ${rebuild-cmd} switch --flake ~/git/dotfiles/.# &| ${pkgs.nix-output-monitor}/bin/nom
  '';
in
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

        copy = if isDarwin then "pbcopy" else "xclip -selection clipboard";
        paste = if isDarwin then "pbpaste" else "xlip -o -selection clipboard";
        cat = "bat";
        "!!" = "eval \\$history[1]";
        clear = "clear && _prompt_move_to_bottom";
        # inspect $PATH
        pinspect = ''echo "$PATH" | tr ":" "\n"'';
      };

      shellInit = ''
        # put Nix profile *first* on my PATH
        export PATH="$HOME/.nix-profile/bin:$PATH"
        set -g fish_prompt_pwd_dir_length 20
      '';

      interactiveShellInit = ''
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
          body = ''
            echo
            echo
            string repeat -n (tput cols) '─'
            echo
            echo
          '';
        };
        nix-apply = {
          description = "Apply latest Nix configuration; checks if you need to do a git pull first";
          body = ''
            # Check for offline flag
            set -l offline 0
            for arg in $argv
                if test "$arg" = -o -o "$arg" = --offline
                    set offline 1
                    break
                end
            end

            # Skip git checks if offline mode is enabled
            if test $offline -eq 0
                pushd $HOME/git/dotfiles >/dev/null 2>&1
                git fetch
                if test (git rev-list --left-right --count origin/master...@ | cut -f1) -gt 0
                    echo "Current revision is behind origin/master"
                    echo "Affected files:"
                    git diff --stat @..origin/master
                    popd >/dev/null 2>&1
                    return 1
                end
                popd >/dev/null 2>&1
            else
                echo "Running in offline mode, skipping git status checks."
            end
            ${rebuild-script}
            for s in $pipestatus
                if test $s -ne 0
                    echo "Pipeline failed with status $s"
                    return $s
                end
            end
          '';
        };
        nix-clean = {
          description = "Run Nix garbage collection and remove old kernels to free up space in boot partition";
          body = ''
            # NixOS-specific steps
            if test -f /etc/NIXOS
                sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +3
                for link in /nix/var/nix/gcroots/auto/*
                    rm $(readlink "$link")
                end
            end
            nix-env --delete-generations old
            nix-store --gc
            nix-channel --update
            nix-env -u --always
            nix-collect-garbage -d
          '';
        };
        groot = {
          description = "cd to the root of the current git repository";
          body = ''
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
          body = ''
            for ARG in $argv
                if [ "$ARG" = --run ]
                    command nix-shell $argv
                    return $status
                end
            end
            command nix-shell $argv --run "exec fish"
          '';
        };
        mr = ''
          set -l GITLAB_BASE_URL "https://gitlab.1password.io"
          set -l PROJECT_PATH (git config --get remote.origin.url | sed 's/^ssh.*@[^/]*\(\/.*\).git/\1/g')
          set -l GIT_BRANCH (git branch --show-current)
          if test -z "$GIT_BRANCH"
              set GIT_BRANCH (jj log -r @- --no-graph --no-pager -T 'self.bookmarks()')
          end
          if test -z "$GIT_BRANCH"
              echo "Error: not a git repo"
              return 1
          end
          set -l GITLAB_MR_URL "$GITLAB_BASE_URL$PROJECT_PATH/-/merge_requests/new?merge_request%5Bsource_branch%5D=$GIT_BRANCH"
          ${if isLinux then "xdg-open" else "open"} "$GITLAB_MR_URL"
        '';
        pr = ''
          set -l PROJECT_PATH (git config --get remote.origin.url)
          set -l PROJECT_PATH (string replace "git@github.com:" "" "$PROJECT_PATH")
          set -l PROJECT_PATH (string replace "https://github.com/" "" "$PROJECT_PATH")
          set -l PROJECT_PATH (string replace ".git" "" "$PROJECT_PATH")
          set -l GIT_BRANCH (git branch --show-current || echo "")
          set -l MASTER_BRANCH (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

          if test -z "$GIT_BRANCH"
              set GIT_BRANCH (jj log -r @- --no-graph --no-pager -T 'self.bookmarks()')
          end

          if test -z "$GIT_BRANCH"
              echo "Error: not a git repository"
              return 1
          end
          ${
            if isLinux then "xdg-open" else "open"
          } "https://github.com/$PROJECT_PATH/compare/$MASTER_BRANCH...$GIT_BRANCH"
        '';
        login = {
          description = "Select a 1Password item via fzf and open it in browser";
          body = ''
            set -l selected (op item list --categories login --format json | ${pkgs.jq}/bin/jq -r '.[].title' | fzf --height 40% --layout reverse | xargs op item get --format=json | ${pkgs.jq}/bin/jq -r '.id, .urls[0].href')
            if [ -z "$selected" ]
                commandline -f repaint
                return
            end
            set -l id $selected[1]
            set -l url $selected[2]
            # if it has a ? then append query string with &
            if string match -e -- '\?' "$url"
                set -f fill_session_url "$url&$id=$id"
            else
                # otherwise append query string with ?
                set -f fill_session_url "$url?$id=$id"
            end
            ${if isLinux then "xdg-open" else "open"} "$fill_session_url"
          '';
        };
      };
    };
  };

  home.packages =
    with pkgs;
    [
      nix-output-monitor
      tealdeer
      tokei
      cachix
      jq
      ripgrep
      gnused
    ]
    ++ lib.lists.optionals isLinux [ xclip ];

}
