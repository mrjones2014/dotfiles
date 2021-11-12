alias sourcefish="source ~/.config/fish/config.fish && echo 'Fish shell profile reloaded.'"

# Alias for dotfiles management
alias dots="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

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

alias gogit="cd ~/git"

# since I can never find the site easily
alias kitty-docs="open https://sw.kovidgoyal.net/kitty/"

complete --no-files --command conf --arguments "(getConfCompletions (commandline -cp))"
function getConfCompletions
    set -l currentPath (string trim (string replace "conf " "" $argv[1]))
    set -l allPaths (sed -e 's/:[^:\/\/].*/=/g;s/$//g;s/ *=//g' $HOME/.config-paths.yml)
    set -l matchingPaths ""
    for path in $allPaths
        if string match -q -- "*$currentPath*" "$path"
            # if first match, don't add newline
            if test -z "$matchingPaths"
                set matchingPaths "$path"
            else
                set matchingPaths "$matchingPaths"\n"$path"
            end
        end
    end
    echo $matchingPaths
end

function conf
    set -l SUBJECT_NAME $argv[1]
    set -l CONFIG_PATH (grep -A3 "$SUBJECT_NAME:" ~/.config-paths.yml | head -n1 | awk '{ print $2 }')
    if [ -z "$CONFIG_PATH" ]
        echo "$SUBJECT_NAME not configured in ~/.config-paths.yml"
        return
    end

    set -l CONFIG_FULL_PATH "$HOME/$CONFIG_PATH"

    if [ "$SUBJECT_NAME" = fish ]
        pushd "$HOME/$CONFIG_PATH" && nvim && popd && sourcefish # if fish, also reload fish profile
    else if [ "$SUBJECT_NAME" = vim ]
        pushd "$HOME/$CONFIG_PATH" && nvim && popd && nvim --headless +PackerCompile +qall! # if configuring nvim, recompile packer automatically
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

function nuke-from-orbit
    nuke-docker
    killall node
    killall hugo
end

function groot
    set -l git_repo_root_dir (git rev-parse --show-toplevel)
    if test -n "$git_repo_root_dir"
        cd "$git_repo_root_dir"
    end
end

# Send a single command to all panes without
# having to toggle on and off the
# synchronize-panes option manually
function tmux-send-all-panes
    set -l current_pane (tmux display-message -p '#P')
    for pane in (tmux list-panes -F '#P')
        if [ "$pane" = "$current_pane" ]
            eval $argv
        else
            # I only want to send nvim command to current pane
            set -l cmd (string replace " nvim" "" "$argv")
            tmux send-keys -t $pane "$cmd" Enter
        end
    end
end

function find-projects
    set -l work_projects (exa -1 ~/git/work)
    set -l personal_projects (exa -1 ~/git/personal)
    set -l local_fzf_dir_find (string join \n $work_projects $personal_projects | grep -v .DS_Store | fzf --query="$1" --select-1 --exit-0)
    if test -n "$local_fzf_dir_find"
        if string match $local_fzf_dir_find $work_projects &>/dev/null
            echo "~/git/work/$local_fzf_dir_find"
        else if string match $local_fzf_dir_find $personal_projects &>/dev/null
            echo "~/git/personal/$local_fzf_dir_find"
        end
    end
end

# fzf find a directory and cd to it
function f
    set -l local_fzf_dir_cd (find-projects)
    if test -n "$local_fzf_dir_cd"
        if test -z "$TMUX"
            cd "$local_fzf_dir_cd"
        else
            tmux-send-all-panes "cd $local_fzf_dir_cd; clear"
        end
    end
end

# fzf find a directory, cd to it, and open it in nvim
function fo
    set -l local_fzf_dir_open (find-projects)
    if test -n "$local_fzf_dir_open"
        if test -z "$TMUX"
            cd "$local_fzf_dir_open"
            nvim
        else
            tmux-send-all-panes "cd $local_fzf_dir_open; clear"
            nvim
        end
    end
end

function update-globals
    brew update
    brew upgrade --fetch-HEAD
    pushd ~/git/personal/lua-language-server/
    git fetch
    set -l updates (git log HEAD..origin/master --oneline)
    if test -n "$updates"
        git merge && git submodule update --recursive
        pushd 3rd/luamake && compile/install.sh && popd && ./3rd/luamake/luamake rebuild
    end
    popd
    yarn global upgrade
    nvim --headless +PackerCompile +qall!
end
