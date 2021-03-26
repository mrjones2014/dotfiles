highlight Blamer ctermfg=grey guifg=grey
let g:blamer_enabled = 1
let g:blamer_delay = 200
let g:blamer_show_in_insert_modes = 0
let g:blamer_show_in_visual_modes = 0
let g:blamer_prefix = " > "

let g:startify_lists = [
	\ { 'type': 'dir',       'header': ['Recent Files in '. getcwd()] },
	\ { 'type': 'files',     'header': ['Recent Files (Global)'] },
	\ { 'type': 'sessions',  'header': ['Sessions'] },
\ ]

" indent guides color
let g:indentLine_color_term = 59
let g:indentLine_color_gui = '#5f5f5f'
" disable indentLine in markdown cause its glitchy when trying to write
" code-fences
let g:indentguides_ignorelist = ['markdown']

" set gohtmltmpl commentary string to html comments
autocmd FileType gohtmltmpl setlocal commentstring=<\!--\ %s\ -->

" vim-make.vim config
let g:VimMake_win_pos = 'right'
let g:VimMake_win_size = '40'

" automatically sleuth indent styles
let g:sleuth_automatic = 1
