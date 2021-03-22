export GPG_TTY=(tty)

source $HOME/.config/fish/check-globals.fish

set FZF_DEFAULT_COMMAND 'ag --hidden --ignore .git -g ""'
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --color=fg:#d0d0d0,bg:#000000,hl:#5f87af --color=fg+:#d0d0d0,bg+:#2b2a2a,hl+:#5f87af --color=info:#4cc853,prompt:#4cc853,pointer:#ff77ff --color=marker:#4cc853,spinner:#ff77ff,header:#87afaf"

set PATH $PATH "$HOME/scripts"

source $HOME/.config/fish/aliases.fish

if ! type starship >/dev/null
    echo 'Install starship: https://github.com/starship/starship'
else
    # MUST BE LAST LINE
    starship init fish | source
end
