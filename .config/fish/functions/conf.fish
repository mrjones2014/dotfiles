complete --no-files --command conf --arguments "(getConfCompletions (commandline -cp))"
function getConfCompletions
    set -l currentPath (string trim (string replace "conf " "" $argv[1]))
    set -l allPaths (sed -e 's/:[^:\/\/].*/=/g;s/$//g;s/ *=//g' $HOME/.config/config-paths.yml)
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
    set -l CONFIG_PATH (grep -A3 "$SUBJECT_NAME:" ~/.config/config-paths.yml | head -n1 | awk '{ print $2 }')
    if [ -z "$CONFIG_PATH" ]
        echo "$SUBJECT_NAME not configured in ~/.config/config-paths.yml"
        return
    end

    set -l CONFIG_FULL_PATH "$HOME/$CONFIG_PATH"

    if [ "$SUBJECT_NAME" = fish ]
        pushd "$HOME/$CONFIG_PATH" && nvim && popd && sourcefish # if fish, also reload fish profile
    else if [ "$SUBJECT_NAME" = vim ]
        pushd "$HOME/$CONFIG_PATH" && nvim && popd && nvim --headless +PackerSync +qall! # if configuring nvim, recompile packer automatically
    else if test -f "$CONFIG_FULL_PATH"
        nvim "$CONFIG_FULL_PATH" # if path is a file, not a directory, don't pushd, just nvim
    else if test -d "$CONFIG_FULL_PATH"
        pushd "$CONFIG_FULL_PATH" && nvim && popd
    else
        echo "Path given is not a file or directory."
    end
end
