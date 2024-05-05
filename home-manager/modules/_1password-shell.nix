{ inputs, pkgs, ... }:
let
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
  home = {
    sessionVariables.SUDO_ASKPASS = "${op_sudo_password_script}";
    packages = with pkgs; [ _1password ];
  };
  imports = [ inputs._1password-shell-plugins.hmModules.default ];
  programs = {
    fish = {
      shellAliases.sudo = "sudo -A";
      shellInit = ''
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
      '';
      functions.opauthsock = {
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
    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [ gh ];
    };
  };
}
