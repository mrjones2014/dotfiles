local g = vim.g
local api = vim.api

require('github-theme').setup({
  themeStyle = 'dark',
  sidebars = {'packer', 'NvimTree', 'term', 'terminal', 'fzf'},
})

vim.cmd([[
  filetype plugin on
  colorscheme github
]])
