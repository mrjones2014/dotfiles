export GPG_TTY=(tty)

source $HOME/.config/fish/check-globals.fish

set FZF_DEFAULT_COMMAND 'ag --hidden --ignore .git -g ""'

set PATH $PATH "$HOME/scripts"

source $HOME/.config/fish/aliases.fish

if ! type starship >/dev/null
    echo 'Install starship: https://github.com/starship/starship'
else
    # MUST BE LAST LINE
    starship init fish | source
end
