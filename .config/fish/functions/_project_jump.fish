function _project_jump_get_icon
    set -l remote "$(git ls-remote --get-url 2> /dev/null)"
    if string match -r "github.com" "$remote" >/dev/null
        set_color --bold normal
        echo -n 
    else if string match -r gitlab "$remote" >/dev/null
        set_color --bold FC6D26
        echo -n 
    end
end

function _project_jump_format_project
    pushd "$HOME/git/$argv[1]"
    set -l branch (git branch --show-current)
    set_color --bold cyan
    echo -n "$argv[1]"
    echo -n " $(_project_jump_get_icon)"
    set_color --bold f74e27
    echo "  $branch"
    popd
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
    set -l ls_cmd (which ls)
    for dir in ($ls_cmd "$HOME/git")
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
    if test "$argv[1]" = --format && test -n "$argv[2]"
        _project_jump_get_readme $argv[2]
    else
        set -l selected (_project_jump_get_projects | fzf --ansi --preview "_project_jump --format {}" | _project_jump_parse_project)
        if test -n "$selected"
            cd "$selected"
        end
        commandline -f repaint
    end
end
