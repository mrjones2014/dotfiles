# Lighthaus FZF Theme
# https://github.com/lighthaus-theme/fzf

set -l FZF_NON_COLOR_OPTS

for arg in (echo $FZF_DEFAULT_OPTS | tr " " "\n")
    if not string match -q -- "--color*" $arg
        set -a FZF_NON_COLOR_OPTS $arg
    end
end

set FZF_DEFAULT_OPTS "$FZF_NON_COLOR_OPTS\
--color=fg:#CCCCCC,bg:#000000,hl:#FFFF00 \
--color=fg+:#FFEE79,bg+:#21252D,hl+:#ED722E \
--color=info:#D68EB2,prompt:#50C16E,pointer:#FFFF00 \
--color=marker:#FC2929,spinner:#FF4D00,header:#1D918B"
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"

# now my custom configs
set FZF_DEFAULT_COMMAND 'rg --hidden --ignore .git --ignore .DS_Store -g ""'
