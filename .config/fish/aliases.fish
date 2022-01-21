alias sourcefish="source ~/.config/fish/config.fish && fish_logo"

# Alias for dotfiles management
alias dots="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# alias vi and vim to open nvim instead
alias vim="nvim"
alias vi="nvim"
alias v="nvim"

function nvim
    set -l NVIM (which nvim)
    if test (count $argv) -lt 1
        "$NVIM"
        return
    end

    if test -d $argv[1]
        pushd $argv[1] && "$NVIM" && popd
        return
    end

    "$NVIM" $argv
end

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
