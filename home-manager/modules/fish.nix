{ pkgs, lib, ... }:
let
  inherit (pkgs) stdenv;
  inherit (stdenv) isLinux;
  op_sudo_password_script = pkgs.writeScript "opsudo.bash" ''
    #!${pkgs.bash}/bin/bash
    ${pkgs._1password}/bin/op item get "System Password" --fields password
  '';
  op-shell-plugins = [ "gh" ];
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
    [ wget thefuck gh jq glow exa tealdeer tokei cachix _1password ]
    ++ lib.lists.optionals isLinux [ xclip ];

  programs.gh.enable = true;

  programs.fish = {
    enable = true;

    plugins = [{
      name = "foreign-env";
      src = pkgs.fetchFromGitHub {
        owner = "oh-my-fish";
        repo = "plugin-foreign-env";
        rev = "3ee95536106c11073d6ff466c1681cde31001383";
        hash = "sha256-vyW/X2lLjsieMpP9Wi2bZPjReaZBkqUbkh15zOi8T4Y=";
      };
    }];

    shellAliases = {
      cat = "bat";
      gogit = "cd ~/git";
      "!!" = "eval \\$history[1]";
      ls = "exa -a --icons --color=always -s type -F";
      la = "ls -a";
      ll = "ls -l --git";
      l = "ls -laH";
      lg = "ls -lG";
      sudo = "sudo -A";
      nix-apply = if pkgs.stdenv.isDarwin then
        "home-manager switch --flake ~/git/dotfiles/.#mac"
      else
        "sudo nixos-rebuild switch --flake ~/git/dotfiles/.#pc";
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

      fish_add_path "$CARGO_HOME/bin"
    '';

    interactiveShellInit = ''
      fish_vi_key_bindings
      bind -M insert jk "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

      for mode in insert default normal
        # bind -M $mode \a _project_jump
      end

      export OP_PLUGIN_ALIASES_SOURCED=1
      ${lib.concatMapStrings
      (plugin: ''alias ${plugin}="op plugin run -- ${plugin}"'')
      op-shell-plugins}

      # I like to keep the prompt at the bottom rather than the top
      # of the terminal window so that running `clear` doesn't make
      # me move my eyes from the bottom back to the top of the screen;
      # keep the prompt consistently at the bottom
      tput cup $LINES
      # this alias doesn't work from Nix `shellAliases` definition because
      # it uses a variable and aliases get single-quotes instead of double-quoted
      alias clear="clear && tput cup \$LINES";
    '';

    functions = {
      fish_greeting = "";
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
