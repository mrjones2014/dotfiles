{ pkgs, lib, inputs, ... }:
let
  inherit (pkgs) stdenv;
  inherit (stdenv) isLinux;
  op_sudo_password_script = pkgs.writeScript "opsudo.bash" ''
    #!${pkgs.bash}/bin/bash
    # TODO figure out a way to do this without silently depending on `op` being on $PATH
    # using `$\{pkgs._1password}/bin/op` results in unable to connect to desktop app
    PASSWORD="$(op item get "System Password" --fields password)"
    if [[ -z "$PASSWORD" ]]; then
      echo "Failed to get password from 1Password."
      read -s -p "Password: " PASSWORD
    fi

    echo $PASSWORD
  '';
in {
  home.sessionVariables = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    HOMEBREW_NO_ANALYTICS = "1";
    CARGO_NET_GIT_FETCH_WITH_CLI = "true";
    GOPATH = "$HOME/go";
    GIT_MERGE_AUTOEDIT = "no";
    NEXT_TELEMETRY_DISABLED = "1";
    SUDO_ASKPASS = "${op_sudo_password_script}";
  };

  home.packages = with pkgs;
    [ tealdeer tokei cachix _1password btop ]
    ++ lib.lists.optionals isLinux [ xclip ];

  imports = [ inputs._1password-shell-plugins.hmModules.default ];
  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [ gh ];
  };
  programs.fish = {
    enable = true;

    plugins = [{
      name = "foreign-env";
      inherit (pkgs.fishPlugins.foreign-env) src;
    }];

    shellAliases = {
      copy =
        if pkgs.stdenv.isDarwin then "pbcopy" else "xclip -selection clipboard";
      paste = if pkgs.stdenv.isDarwin then
        "pbpaste"
      else
        "xlip -o -selection clipboard";
      cat = "bat";
      gogit = "cd ~/git";
      "!!" = "eval \\$history[1]";
      ls = "${pkgs.lsd}/bin/lsd --group-directories-first";
      la = "ls -a";
      ll = "ls -l --git";
      l = "ls -laH";
      lg = "ls -lG";
      sudo = "sudo -A";
      clear = "clear && _prompt_move_to_bottom";
      nix-apply = if pkgs.stdenv.isDarwin then
        "home-manager switch --flake ~/git/dotfiles/.#mac"
      else
        "sudo nixos-rebuild switch --flake ~/git/dotfiles/.#pc";
      nix-server-apply =
        "sudo nixos-rebuild switch --flake ~/git/dotfiles/.#server";
      oplocal =
        "./js/oph/dist/mac-arm64/1Password.app/Contents/MacOS/1Password";
    } // pkgs.lib.optionalAttrs isLinux {
      cfgnix = "sudo nvim /etc/nixos/configuration.nix";
      restart-gui = "sudo systemctl restart display-manager.service";
    };

    shellInit = ''
      set -g fish_prompt_pwd_dir_length 20

      # Setting up SSH_AUTH_SOCK here rather than ~/.ssh/config
      # because that overrides the environment variables,
      # meaning I can't easily switch between the production and
      # debug auth sockets while working on the 1Password desktop app
      set -g -x SSH_TTY (tty)
      if [ "$(uname)" = Darwin ]
        set -g -x SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      else
        set -g -x SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
      end

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
        body = "cd $HOME/git && git clone $argv && cd $(basename $argv .git)";
      };
      nix-clean = ''
        nix-env --delete-generations old
        nix-store --gc
        nix-channel --update
        nix-env -u --always
        if test -f /etc/NIXOS
            for link in /nix/var/nix/gcroots/auto/*
                rm $(readlink "$link")
            end
        end
        nix-collect-garbage -d
      '';
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
      opauthsock = {
        argumentNames = [ "mode" ];
        description =
          "Configure 1Password SSH agent to use production or debug socket path";
        body = ''
          # complete -c opauthsock -n __fish_use_subcommand -xa prod -d 'use production socket path'
          # complete -c opauthsock -n __fish_use_subcommand -xa debug -d 'use debug socket path'
          # complete -c opauthsock -n 'not __fish_use_subcommand' -f

            if test -z $mode
              echo $SSH_AUTH_SOCK
            else
              set -f prefix "$HOME/.1password"
              if [ "$(uname)" = Darwin ]
                set -f prefix "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password"
              end
              echo "setting ssh auth sock to: $mode"
              switch $mode
                case prod
                  set -g -x SSH_AUTH_SOCK "$prefix/t/agent.sock"
                case debug
                  set -g -x SSH_AUTH_SOCK "$prefix/t/debug/agent.sock"
              end
            end
        '';
      };
    };
  };
}
