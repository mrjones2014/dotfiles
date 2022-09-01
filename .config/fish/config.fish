set -g fish_prompt_pwd_dir_length 20
set -u fish_greeting ""

set -x GPG_TTY (tty)
set -x EDITOR nvim
set -x DOTNET_CLI_TELEMETRY_OPTOUT 1
set -x HOMEBREW_NO_ANALYTICS 1
set -x CARGO_NET_GIT_FETCH_WITH_CLI true

fish_add_path /opt/homebrew/bin
fish_add_path "$HOME/scripts"
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.dotnet/tools"

source $HOME/.config/fish/fzf-config.fish
source $HOME/.config/fish/aliases.fish

# for local-only, non-sync'd stuff
if test -e $HOME/.config/fish/local.fish
    source $HOME/.config/fish/local.fish
end

# setup symlink for Linux compatiblity for 1Password SSH agent
if test -e "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" && test ! -e "$HOME/.1password/agent.sock"
    mkdir -p ~/.1password && ln -s ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock
end

if status is-interactive
    # workaround for https://github.com/fish-shell/fish-shell/issues/3481
    function fish_vi_cursor
    end
    fish_vi_key_bindings
    bind -M insert jk "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

    op completion fish | source
    thefuck --alias | source
    atuin init fish | source
    starship init fish | source
    bind -M insert \e\[A _atuin_search
    set CTRLG_TMUX true
    set CTRLG_TMUX_POPUP true
    set CTRLG_TMUX_POPUP_ARGS -w "75%" -h "85%" -x 10
    ctrlg init fish | source

    set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

    # start tmux session by default
    if [ -z "$TMUX" ]
        if [ "$START_TMUX_PLEASE" = 1 ]
            exec tmux new-session -A -s $USER
        else if [ "$SSH_CLIENT" != "" ]
            exec tmux new-session -A -s ssh-user
        end
    end

    # push prompt to bottom
    for i in (seq 1 $LINES)
        printf '\n'
    end
end
