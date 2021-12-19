# Lighthaus FZF Theme
# https://github.com/lighthaus-theme/fzf

set -l FZF_NON_COLOR_OPTS

for arg in (echo $FZF_DEFAULT_OPTS | tr " " "\n")
    if not string match -q -- "--color*" $arg
        set -a FZF_NON_COLOR_OPTS $arg
    end
end

set FZF_DEFAULT_OPTS "$FZF_NON_COLOR_OPTS"\
" --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D"\
" --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C"\
" --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D"



set FZF_DEFAULT_OPTS "$FZF_NON_COLOR_OPTS\
    --color=fg:#CCCCCC,bg:#18191E,hl:#FFFF00\
    --color=fg+:#FFEE79,bg+:#21252D,hl+:#ED722E\
    --color=info:#D68EB2,prompt:#50C16E,pointer:#FFFF00\
    --color=marker:#FC2929,spinner:#FF4D00,header:#1D918B"

# now my custom configs
set FZF_DEFAULT_COMMAND 'ag --hidden --ignore .git --ignore .DS_Store -g ""'
