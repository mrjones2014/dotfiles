{ pkgs, lib, isDarwin, isLinux, isServer, ... }: {
  home.sessionVariables = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    HOMEBREW_NO_ANALYTICS = "1";
    CARGO_NET_GIT_FETCH_WITH_CLI = "true";
    GOPATH = "$HOME/go";
    GIT_MERGE_AUTOEDIT = "no";
    NEXT_TELEMETRY_DISABLED = "1";
  };
  programs = {
    btop = { enable = true; };

    fish = {
      enable = true;

      plugins = [{
        name = "foreign-env";
        inherit (pkgs.fishPlugins.foreign-env) src;
      }];

      shellAliases = {
        copy = if isDarwin then "pbcopy" else "xclip -selection clipboard";
        paste = if isDarwin then "pbpaste" else "xlip -o -selection clipboard";
        cat = "bat";
        gogit = "cd ~/git";
        "!!" = "eval \\$history[1]";
        ls = "${pkgs.lsd}/bin/lsd --group-directories-first";
        la = "ls -a";
        ll = "ls -l --git";
        l = "ls -laH";
        lg = "ls -lG";
        clear = "clear && _prompt_move_to_bottom";
        oplocal =
          "./js/oph/dist/mac-arm64/1Password.app/Contents/MacOS/1Password";
      } // pkgs.lib.optionalAttrs isLinux {
        cfgnix = "sudo nvim /etc/nixos/configuration.nix";
        restart-gui = "sudo systemctl restart display-manager.service";
      };

      shellInit = ''
        set -g fish_prompt_pwd_dir_length 20

        # Source nix files, required to set fish as default shell, otherwise
        # it doesn't have the nix env vars
        if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]
          fenv source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        end
      '';

      interactiveShellInit = ''
        fish_vi_key_bindings
        bind -M insert jk "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

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
        clone = {
          description = "Clone a git repository, then cd into it.";
          body = ''
            echo "cd ~/git/"
            cd $HOME/git
            git clone $argv && cd $(basename $argv .git)
          '';
        };
        nix-apply = {
          description =
            "Apply latest Nix configuration; checks if you need to do a git pull first";
          body = ''
            argparse --name nix-apply 'o/offline' -- $argv
            or return 1

            pushd ~/git/dotfiles
            if not set _flag_offline
              echo "syncing with remote..."
              git fetch > /dev/null && echo "" || return 1
              set -l gitstatus $(git log HEAD..origin/$(git branch --show-current))
              if "$gitstatus" != ""
                echo "Run `git pull` in ~/git/dotfiles first"
                return 1
              end
            end
            popd
            ${if isDarwin then
              "home-manager switch --flake ~/git/dotfiles/.#mac"
            else if isServer then
              "sudo nixos-rebuild switch --flake ~/git/dotfiles/.#server"
            else
              "sudo nixos-rebuild switch --flake ~/git/dotfiles/.#pc"}
          '';
        };
        nix-clean = {
          description =
            "Run Nix garbage collection and remove old kernels to free up space in boot partition";
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
          set -l CURRENT_BRANCH_NAME (git branch --show-current)
          set -l GITLAB_MR_URL "$GITLAB_BASE_URL$PROJECT_PATH/-/merge_requests/new?merge_request%5Bsource_branch%5D=$CURRENT_BRANCH_NAME"
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
            echo "Error: not a git repository"
          else
            ${
              if isLinux then "xdg-open" else "open"
            } "https://github.com/$PROJECT_PATH/compare/$MASTER_BRANCH...$GIT_BRANCH"
          end
        '';
        login = {
          description =
            "Select a 1Password item via fzf and open it in browser";
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
        kg = {
          description = "Search with Kagi";
          body = ''
            set -l query "$(string escape --style=url $(string join ' ' $argv))"
            ${
              if isDarwin then "open" else "xdg-open"
            } "https://kagi.com/search?token=$(op item get 'Kagi' --fields 'token')&q=$query"
          '';
        };
      };
    };
  };

  home.packages = with pkgs;
    [ tealdeer tokei cachix jq ] ++ lib.lists.optionals isLinux [ xclip ];

}
