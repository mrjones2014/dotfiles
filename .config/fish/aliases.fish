alias fishconfig="vim ~/.config/fish/config.fish"
alias sourcefish="source ~/.config/fish/config.fish"
alias docker-login-local="docker login registry.1password.io -u local-registry"
alias aliases="vim ~/.config/fish/aliases.fish"

alias config="git --git-dir=$HOME/.cfg/ --work-tree=$HOME"

alias vim="nvim" # alias vim to always open neovim instead

# fzf find a directory and return the selected value
function ffind
    echo (sed '1d' $HOME/.cache/neomru/directory | fzf --query="$1" --select-1 --exit-0)
end

# fzf find a directory and cd to it
function f
    set -l local_fzf_dir_cd (sed '1d' $HOME/.cache/neomru/directory | fzf --query="$1" --select-1 --exit-0)
    cd $local_fzf_dir_cd
end

# fzf find a directory, cd to it, and open it in nvim
function fopen
    set -l local_fzf_dir_open (ffind)
    cd $local_fzf_dir_open
    nvim .
end

# Custom public functions
# nvminstall
# usage:
# `nvminstall {node_version_to_install} {node_version_to_uninstall}`
# example:
# `nvminstall 8.1.0 8.0.0`
function nvminstall
    set -l nvminstall_num_args (count $argv)
    if test $nvminstall_num_args -eq 2
        nvm install "$1" && nvm alias default "$1" && nvm reinstall-packages "$2" && nvm uninstall "$2" && npm install -g npm
    else
        echo "
    Usage:
      nvminstall {node_version_to_install} {node_version_to_uninstall}

      Example: \n nvminstall 8.1.0 8.0.0"
    end
end
