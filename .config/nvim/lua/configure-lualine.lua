local icons = require('nvim-nonicons')

local function filepath()
  local path = vim.fn.expand('%')
  if vim.fn.winwidth(0) <= 84 then
    path = vim.fn.pathshorten(path)
  end
  return icons.get('file') .. '  ' .. path
end

require('lualine').setup({
  options = {
    theme = 'tokyonight',
    disabled_filetypes = {'NvimTree', 'term', 'terminal', 'fzf'},
  },
  sections = {
    lualine_a = {{'mode', lower = false}},
    lualine_b = {'branch'},
    lualine_c = {{'diagnostics', sources = {'nvim_lsp'}, sections = {'error', 'warn', 'info', 'hint'}}, filepath},
    lualine_x = {'location'}
  },
  extensions = {'nvim-tree'},
})
