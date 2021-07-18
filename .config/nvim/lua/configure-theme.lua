local g = vim.g
local api = vim.api

require('github-theme').setup({ themeStyle = "dark" })

vim.cmd([[
  syntax on
  set termguicolors
  colorscheme github
  highlight TrailingWhitespace ctermbg=red guibg=red
  match TrailingWhitespace /\s\+$/
]])
