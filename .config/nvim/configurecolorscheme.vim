" theme
syntax on
set t_Co=256
set t_ut=
let g:codedark_term256=1
colorscheme codedark

" this has to come after color scheme is set up
" highlight redundant trailing whitespace with colorscheme's error color
highlight TrailingWhitespace ctermbg=red guibg=red
match TrailingWhitespace /\s\+$/
