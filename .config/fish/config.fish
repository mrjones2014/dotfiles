export GPG_TTY=(tty)

source $HOME/.config/fish/check-globals.fish

eval (/opt/homebrew/bin/brew shellenv)

if test -f "/opt/homebrew/bin/brew"
    eval (/opt/homebrew/bin/brew shellenv)
end

thefuck --alias | source

set FZF_DEFAULT_COMMAND 'ag --hidden --ignore .git --ignore .DS_Store -g ""'
set FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --color=fg:#d0d0d0,bg:#000000,hl:#5f87af --color=fg+:#d0d0d0,bg+:#2b2a2a,hl+:#5f87af --color=info:#4cc853,prompt:#4cc853,pointer:#ff77ff --color=marker:#4cc853,spinner:#ff77ff,header:#87afaf"

set PATH $PATH "$HOME/scripts"

source $HOME/.config/fish/aliases.fish

if ! type starship >/dev/null
    echo 'Install starship: https://github.com/starship/starship'
else
    starship init fish | source
end

# start tmux session by default
if [ "$TERM" != "screen" ]
    exec tmux
end

check_globals || echo "Some required global packages are not installed. Check output above."
source $HOME/.config/fish/check-architecture.fish
