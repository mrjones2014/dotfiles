# start tmux session by default
if [ -z "$TMUX" ]
    exec tmux new-session -A -s $USER
end

export GPG_TTY=(tty)
export EDITOR="nvim"

source $HOME/.config/fish/check-globals.fish

if test -f "/opt/homebrew/bin/brew"
    eval (/opt/homebrew/bin/brew shellenv)
end

thefuck --alias | source

set FZF_DEFAULT_COMMAND 'ag --hidden --ignore .git --ignore .DS_Store -g ""'

set PATH $PATH "$HOME/scripts"
set PATH $PATH "$HOME/git/webbook/scripts"

source $HOME/.config/fish/aliases.fish
source $HOME/.config/fish/check-architecture.fish

if ! type starship >/dev/null
    echo 'Install starship: https://github.com/starship/starship'
else
    starship init fish | source
end

###-begin-yaclt-completions-###
#
# yargs command completion script
#
# Installation: yaclt completion-fish >> ~/.config/fish/config.fish
complete --no-files --command yaclt --arguments "(yaclt --get-yargs-completions (commandline -cp))"


check_globals || echo "Some required global packages are not installed. Check output above."


