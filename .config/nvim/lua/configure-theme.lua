local g = vim.g

local sidebarColor = '#15181b'
g.tokyonight_style = 'night'
g.tokyonight_sidebars = {'packer', 'NvimTree', 'term', 'terminal', 'FTerm'}
g.tokyonight_colors = {bg = '#24292e', bg_dark = '#24292e', bg_sidebar = sidebarColor}

vim.cmd('colorscheme tokyonight')

-- has to be required after theme is set up for highlighting
require('configure-trailing-whitespace')
