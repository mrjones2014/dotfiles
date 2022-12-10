alias sourcefish="source ~/.config/fish/config.fish && fish_logo"

# Alias for dotfiles management
alias dots="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# alias vi and vim to open nvim instead
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias oldvim="$(which vim)"
# lol, sometimes I'm stupid
alias :q="exit"
alias :Q="exit"
# I swear I'm an idiot sometimes
alias :e="nvim"

alias n="nvim $HOME/docs/norg/"

alias update-nvim-plugins="nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"

alias emptytrash="sudo rm -rf ~/.Trash/*"

alias h="_atuin_search"

# alias ls to exa with compatibility aliases
alias ls="exa -a --icons --color=always -s type -F"
alias la="ls -a"
alias ll="ls -l --git"
alias l="ls -laH"
alias lg="ls -lG"

alias gogit="cd ~/git"
alias cdgl="cd ~/git/gitlab"
alias cdgh="cd ~/git/github"

# since I can never find the site easily
alias kitty-docs="open https://sw.kovidgoyal.net/kitty/"
