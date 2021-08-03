local function filepath()
  local path = vim.fn.expand('%')
  if vim.fn.winwidth(0) <= 84 then
    path = vim.fn.pathshorten(path)
  end
  return path
end

require('lualine').setup({
  options = {
    theme = 'github',
  },
  sections = {
    lualine_a = {{'mode', lower = false}},
    lualine_b = {'branch'},
    lualine_c = {filepath},
    lualine_d = {'location'}
  },
  extensions = {'nvim-tree'}
})
