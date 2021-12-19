alias sourcefish="source ~/.config/fish/config.fish && echo 'Fish shell profile reloaded.'"

# Alias for dotfiles management
alias dots="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# alias vi and vim to open nvim instead
alias vim="nvim"
alias vi="nvim"
alias v="nvim"

alias emptytrash="sudo rm -rf ~/.Trash/*"

alias h="_atuin_search"

# alias ls to exa with compatibility aliases
alias ls="exa -a --icons --color=always -s type -F"
alias la="ls -a"
alias ll="ls -l --git"
alias l="ls -laH"
alias lg="ls -lG"

alias gogit="cd ~/git"

# since I can never find the site easily
alias kitty-docs="open https://sw.kovidgoyal.net/kitty/"
