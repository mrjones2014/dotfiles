alias sourcefish="source ~/.config/fish/config.fish && echo 'Fish shell profile reloaded.'"
alias docker-login-local="docker login registry.1password.io -u local-registry"

# Alias for dotfiles management
alias config="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# alias vi and vim to open nvim instead
alias vim="nvim"
alias vi="nvim"
alias v="nvim"

alias emptytrash="sudo rm -rf ~/.Trash/*"

alias h="history | fzf --select-1 --exit-0 | pbcopy"

# alias ls to exa with compatibility aliases
alias ls="exa -a --icons --color=always -s type -F"
alias la="ls -a"
alias ll="ls -l --git"
alias l="ls -laH"
alias lg="ls -lG"

# since I can never find the site easily
alias kitty-docs="open https://sw.kovidgoyal.net/kitty/"

function conf
  set -l SUBJECT_NAME $argv[1]
  set -l CONFIG_PATH (grep -A3 "$SUBJECT_NAME:" ~/.config-paths.yml | head -n1 | awk '{ print $2 }')
  if [ -z "$CONFIG_PATH" ]
    echo "$SUBJECT_NAME not configured in ~/.config-paths.yml"
    return
  end

  set -l CONFIG_FULL_PATH "$HOME/$CONFIG_PATH"

  if [ "$SUBJECT_NAME" = "fish" ]
    pushd "$HOME/$CONFIG_PATH" && nvim && popd && sourcefish # if fish, also reload fish profile
  else if test -f "$CONFIG_FULL_PATH"
    nvim "$CONFIG_FULL_PATH" # if path is a file, not a directory, don't pushd, just nvim
  else if test -d "$CONFIG_FULL_PATH"
    pushd "$CONFIG_FULL_PATH" && nvim && popd
  else
    echo "Path given is not a file or directory."
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
  set -l git_repo_root_dir (git rev-parse --show-toplevel &> /dev/null)
  if test -n "$git_repo_root_dir"
    cd "$git_repo_root_dir"
  else
    echo "I am Groot (translation: not a git repo)"
  end
end

function find_projects
  set -l local_fzf_dir_find (exa -1 --all --level=1 ~/git/ | grep -v .DS_Store | fzf --query="$1" --select-1 --exit-0)
  if test -n "$local_fzf_dir_find"
    echo "$HOME/git/$local_fzf_dir_find"
  end
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

        Example:
          nvminstall 8.1.0 8.0.0
        "
    end
end

