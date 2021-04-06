alias sourcefish="source ~/.config/fish/config.fish && echo 'Fish shell profile reloaded.'"
alias docker-login-local="docker login registry.1password.io -u local-registry"

# Alias for dotfiles management
alias config="git --git-dir=$HOME/.cfg/ --work-tree=$HOME"

# alias vi and vim to open nvim instead
alias vim="nvim"
alias vi="nvim"

alias emptytrash="sudo rm -rf ~/.Trash/*"

function conf
  if [ $argv[1] = "vim" ]
    pushd ~/.config/nvim && nvim && popd
  else if [ $argv[1] = "fish" ]
    pushd ~/.config/fish && nvim && popd && sourcefish
  else if [ $argv[1] = "tmux" ]
    pushd ~/.config/tmux && nvim && popd
  else if [ $argv[1] = "scripts" ]
    pushd ~/scripts && nvim && popd
  else if [ $argv[1] = "term" ]
    pushd ~/.config/alacritty && nvim && popd
  else
    echo "conf $argv[1] is not set up"
  end
end

function nuke-docker
    set -l docker_container_names (docker ps --format "{{.Names}}")
    if test -n "$docker_container_names"
        docker kill $docker_container_names
    else
        echo "No docker containers running."
    end
end

function groot
  set -l git_repo_root_dir (git rev-parse --show-toplevel)
  if test -n "$git_repo_root_dir"
    cd "$git_repo_root_dir"
  else
    echo "Not a git repo"
  end
end

function find_projects
  echo (ls -1Ad ~/git/* | grep -v .DS_Store | fzf --query="$1" --select-1 --exit-0)
end

# fzf find a directory and cd to it
function f
    set -l local_fzf_dir_cd (find_projects)
    if test -n "$local_fzf_dir_cd"
        cd $local_fzf_dir_cd
    end
end

# fzf find a directory, cd to it, and open it in nvim
function fo
    set -l local_fzf_dir_open (find_projects)
    if test -n "$local_fzf_dir_open"
        cd $local_fzf_dir_open
        nvim
    end
end

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

