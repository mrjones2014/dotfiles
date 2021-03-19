highlight Blamer ctermfg=grey guifg=grey
let g:blamer_enabled = 1
let g:blamer_delay = 200
let g:blamer_show_in_insert_modes = 0

let g:startify_lists = [
	\ { 'type': 'dir',       'header': ['Recent Files in '. getcwd()] },
	\ { 'type': 'files',     'header': ['Recent Files (Global)'] },
	\ { 'type': 'sessions',  'header': ['Sessions'] },
\ ]

" indent guides color
let g:indentLine_color_term = 59
let g:indentLine_color_gui = '#5f5f5f'
