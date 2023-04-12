set -g fish_prompt_pwd_dir_length 20
set -u fish_greeting ""

set -x DOTNET_CLI_TELEMETRY_OPTOUT 1
set -x HOMEBREW_NO_ANALYTICS 1
set -x CARGO_NET_GIT_FETCH_WITH_CLI true
set -x GOPATH "$HOME/go"

fish_add_path /opt/homebrew/bin
fish_add_path "$HOME/scripts"
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.dotnet/tools"
fish_add_path "$HOME/.local/share/bob/nvim-bin"

# for local-only, non-sync'd stuff
if test -f $HOME/.config/fish/local.fish
    source $HOME/.config/fish/local.fish
end

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

if status is-interactive
    function installed
        if type "$argv[1]" &>/dev/null
            return 0
        else
            return 1
        end
    end

    fish_vi_key_bindings
    bind -M insert jk "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

    # 1Password Shell Plugins!
    if test -f $HOME/.config/op/plugins.sh
        source $HOME/.config/op/plugins.sh
    end

    source $HOME/.config/fish/fzf-config.fish
    source $HOME/.config/fish/aliases.fish

    if installed op
        op completion fish | source
        # Use 1Password CLI for sudo
        set -x SUDO_ASKPASS "$HOME/scripts/opsudo.bash"
        alias sudo="sudo -A"
    end

    installed thefuck && thefuck --alias | source
    installed starship && starship init fish | source
    installed bob && bob complete fish | source
    installed atuin && atuin init fish | source
    for mode in insert default normal
        installed atuin && bind -M insert \e\[A "_atuin_search; tput cup \$LINES"
        bind -M $mode \a _project_jump
    end
    set -x GIT_MERGE_AUTOEDIT no
    set -x MANPAGER "nvim -c 'Man!' -o -"
    set -x EDITOR nvim

    # start tmux session by default
    if installed tmux && [ -z "$TMUX" ]
        if [ "$START_TMUX_PLEASE" = 1 ]
            exec tmux new-session -A -s $USER
        end
    end

    # I like to keep the prompt at the bottom rather than the top
    # of the terminal window so that running `clear` doesn't make
    # me move my eyes from the bottom back to the top of the screen;
    # keep the prompt consistently at the bottom
    tput cup $LINES
    alias clear="clear && tput cup \$LINES"
end
