let $FZF_DEFAULT_COMMAND ='ag --hidden --ignore .git -g ""'

let vim_fzf_prj_root = getcwd() " evaluate when vim is first opened

command! SearchForFiles execute 'Files' vim_fzf_prj_root
command! -bang -nargs=* SearchForText call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case ' . shellescape(<q-args>) . ' ' . vim_fzf_prj_root, 1, {'options': '--delimiter : --nth 4..'}, <bang>0)

" ctrl+p to fzf
nmap <C-P> :SearchForFiles<CR>

" <leader>f to global fuzzy text search
nmap <leader>f :SearchForText<CR>
