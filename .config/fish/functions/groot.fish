function groot
    set -l git_repo_root_dir (git rev-parse --show-toplevel)
    if test -n "$git_repo_root_dir"
        cd "$git_repo_root_dir"
    end
end
