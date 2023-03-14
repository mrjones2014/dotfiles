function pr

    set -l PROJECT_PATH (git config --get remote.origin.url)
    set -l PROJECT_PATH (string replace "git@github.com:" "" "$PROJECT_PATH")
    set -l PROJECT_PATH (string replace "https://github.com/" "" "$PROJECT_PATH")
    set -l PROJECT_PATH (string replace ".git" "" "$PROJECT_PATH")
    set -l GIT_BRANCH (git branch --show-current || echo "")
    set -l MASTER_BRANCH (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

    if test -z "$GIT_BRANCH"
        then
        echo "Error: not a git repository"
    else
        open "https://github.com/$PROJECT_PATH/compare/$MASTER_BRANCH...$GIT_BRANCH"
    end
end
