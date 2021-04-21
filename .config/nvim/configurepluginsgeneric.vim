let g:startify_lists = [
	\ { 'type': 'dir',       'header': ['Recent Files in '. getcwd()] },
	\ { 'type': 'files',     'header': ['Recent Files (Global)'] },
	\ { 'type': 'sessions',  'header': ['Sessions'] },
\ ]

" disable indentLine in markdown cause its glitchy when trying to write
" code-fences
let g:indentguides_ignorelist = ['markdown', 'json']

" set gohtmltmpl commentary string to html comments
autocmd FileType gohtmltmpl setlocal commentstring=<\!--\ %s\ -->

" vim-make.vim config
let g:VimMake_win_pos = 'right'
let g:VimMake_win_size = '40'

" automatically sleuth indent styles
let g:sleuth_automatic = 1
