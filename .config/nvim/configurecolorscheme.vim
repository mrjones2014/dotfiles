" theme
syntax on
set termguicolors
let ayucolor = "dark"
colorscheme ayu

" this has to come after color scheme is set up because its overriding theme
" colors

" override background color to black
highlight Normal guibg=black ctermbg=black
highlight NonText guibg=black ctermbg=black

" highlight redundant trailing whitespace with colorscheme's error color
highlight TrailingWhitespace ctermbg=red guibg=red
match TrailingWhitespace /\s\+$/
