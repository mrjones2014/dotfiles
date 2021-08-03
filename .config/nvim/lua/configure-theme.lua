local g = vim.g

g.tokyonight_style = 'night'
g.tokyonight_sidebars = {'packer', 'NvimTree', 'term', 'terminal', 'fzf'}
g.tokyonight_colors = {bg = '#24292e', bg_dark = '#24292e', bg_sidebar = '#15181b'}

vim.cmd([[
  filetype plugin on
  colorscheme tokyonight
]])
