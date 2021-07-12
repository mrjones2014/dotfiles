" theme
syntax on
set termguicolors

lua << EOF
require("github-theme").setup({
  themeStyle = "dark"
})
EOF

colorscheme github

" highlight redundant trailing whitespace with colorscheme's error color
highlight TrailingWhitespace ctermbg=red guibg=red
match TrailingWhitespace /\s\+$/
