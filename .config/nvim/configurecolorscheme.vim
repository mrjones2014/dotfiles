" theme
syntax on
" these next 2 lines fix vim not picking up on correct color support in
" Alacritty
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
let g:onedark_termcolors=256
colorscheme onedark

" this has to come after color scheme is set up because its overriding theme
" colors

" override background color to black
highlight Normal guibg=black ctermbg=black
highlight NonText guibg=black ctermbg=black

" highlight redundant trailing whitespace with colorscheme's error color
highlight TrailingWhitespace ctermbg=red guibg=red
match TrailingWhitespace /\s\+$/
