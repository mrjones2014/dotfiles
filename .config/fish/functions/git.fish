function git --description "Git wrapper function to workaround using diffview.nvim as mergetool" --wraps git
    set -l GIT (which git)
    if test (count $argv) -eq 1 && [ "$argv[1]" = mergetool ]
        nvim -c DiffviewOpen
    else
        "$GIT" $argv
    end
end
