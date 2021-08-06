# ensure brew stuff is on PATH
if test -f "/opt/homebrew/bin/brew"
    eval (/opt/homebrew/bin/brew shellenv)
end

# start tmux session by default
if [ -z "$TMUX" ] && [ "$START_TMUX_PLEASE" = 1 ]
    exec tmux new-session -A -s $USER
end

export GPG_TTY=(tty)
export EDITOR="nvim"

set PATH $PATH "$HOME/scripts"
set PATH $PATH "$HOME/git/webbook/scripts"

source $HOME/.config/fish/check-globals.fish
source $HOME/.config/fish/fzf-config.fish
source $HOME/.config/fish/aliases.fish
source $HOME/.config/fish/check-architecture.fish

# for local-only, non-sync'd stuff
if test -e $HOME/.config/fish/local.fish
    source $HOME/.config/fish/local.fish
end

thefuck --alias | source
starship init fish | source

###-begin-yaclt-completions-###
#
# yargs command completion script
#
# Installation: yaclt completion-fish >> ~/.config/fish/config.fish
complete --no-files --command yaclt --arguments "(yaclt --get-yargs-completions (commandline -cp))"
