# Theme based on onedarkpro.nvim

set -l FZF_NON_COLOR_OPTS

for arg in (echo $FZF_DEFAULT_OPTS | tr " " "\n")
    if not string match -q -- "--color*" $arg
        set -a FZF_NON_COLOR_OPTS $arg
    end
end

set -x FZF_DEFAULT_OPTS "$FZF_NON_COLOR_OPTS\
    --color=fg:#abb2bf,bg:#000000,hl:#89ca78
    --color=fg+:#cccccc,bg+:#282c34,hl+:#2bbac5
    --color=info:#89ca78,prompt:#89ca78,pointer:#ef596f
    --color=marker:#89ca78,spinner:#ef596f,header:#d55fde"

# now my custom configs
set -x FZF_DEFAULT_COMMAND 'rg --hidden --ignore .git --ignore .DS_Store -g ""'
