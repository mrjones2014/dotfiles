local g = vim.g
local api = vim.api

require('github-theme').setup({
  themeStyle = 'dark',
  sidebars = {'packer', 'NvimTree', 'term', 'terminal'},
})

vim.cmd([[
  filetype plugin on
  colorscheme github
  highlight TrailingWhitespace ctermbg=red guibg=red
  match TrailingWhitespace /\s\+$/
]])
