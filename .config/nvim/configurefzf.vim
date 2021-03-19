let $FZF_DEFAULT_COMMAND ='ag --hidden --ignore .git -g ""'

command! -bang -nargs=* SearchForText call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case ' . shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
