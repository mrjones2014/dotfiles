function _project_jump_get_icon
    set -l remote "$(git --work-tree $argv[1] --git-dir $argv[1]/.git ls-remote --get-url 2> /dev/null)"
    if string match -r "github.com" "$remote" >/dev/null
        set_color --bold normal
        echo -n 
    else if string match -r gitlab "$remote" >/dev/null
        set_color --bold FC6D26
        echo -n 
    end
end

function _project_jump_format_project
    set -l repo "$HOME/git/$argv[1]"
    set -l branch (git --work-tree $repo --git-dir $repo/.git branch --show-current)
    set_color --bold cyan
    echo -n "$argv[1]"
    echo -n " $(_project_jump_get_icon $repo)"
    set_color --bold f74e27
    echo "  $branch"
end

function _project_jump_parse_project
    read -f selected
    # if not coming from pipe
    if [ "$selected" = "" ]
        # check args
        set -f selected $argv[1]
    end

    # if still empty, return
    if [ "$selected" = "" ]
        return
    end

    set -l dir (string trim "$(string match -r ".*(?=\s*󰊢||)" "$selected")")
    echo "$HOME/git/$dir"
end

function _project_jump_get_projects
    # make sure to use built-in ls, not exa
    for dir in (command ls "$HOME/git")
        if test -d "$HOME/git/$dir"
            echo "$(_project_jump_format_project $dir)"
        end
    end
end

function _project_jump_get_readme
    set -l dir (_project_jump_parse_project "$argv[1]")
    if test -f "$dir/README.md"
        glow -p -s dark -w 150 "$dir/README.md"
    else
        echo
        echo "README.md not found"
    end
end

function _project_jump --description "Fuzzy-find over git repos and jump to them"
    argparse 'format=' -- $argv
    if set -ql _flag_format
        _project_jump_get_readme $_flag_format
    else
        set -l selected (_project_jump_get_projects | fzf --ansi --preview-window 'right,70%' --preview "_project_jump --format {}" | _project_jump_parse_project)
        if test -n "$selected"
            cd "$selected"
        end
        commandline -f repaint
    end
end
