function groot --description "cd to the root of the current git repository"
    set -l git_repo_root_dir (git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$git_repo_root_dir"
        cd "$git_repo_root_dir"
    else
        echo "Not in a git repository."
    end
end
