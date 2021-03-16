let $FZF_DEFAULT_COMMAND ='ag --hidden --ignore .git -g ""'

let vim_fzf_prj_root = getcwd() " evaluate when vim is first opened

command! SearchShit execute 'Files' vim_fzf_prj_root

" ctrl+p to fzf
nmap <C-P> :SearchShit<CR>
