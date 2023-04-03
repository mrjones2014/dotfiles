complete -c opauthsock -n __fish_use_subcommand -xa prod -d 'use production socket path'
complete -c opauthsock -n __fish_use_subcommand -xa debug -d 'use debug socket path'
complete -c opauthsock -n 'not __fish_use_subcommand' -f

function opauthsock -d 'configure the op ssh auth socket' -a mode
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
end
