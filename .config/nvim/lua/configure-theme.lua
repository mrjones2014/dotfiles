local g = vim.g

local sidebarColor = '#15181b'
g.tokyonight_style = 'night'
g.tokyonight_sidebars = {'packer', 'NvimTree', 'term', 'terminal', 'TelescopePrompt'}
g.tokyonight_colors = {bg = '#24292e', bg_dark = '#24292e', bg_sidebar = sidebarColor}

vim.cmd('colorscheme tokyonight')

local telescopeColorAutoCmd = [[
  function SetTelescopeCustomColors()
    highlight TelescopeNormal guibg=$sidebarColor
  endfunction

  augroup TelescopeCustomColorConfig
    autocmd VimEnter * :call SetTelescopeCustomColors()
  augroup END
]]

-- Home-grown variable interpolation so I can have the sidebarColor as a variable
vim.cmd(telescopeColorAutoCmd:gsub('$(%w+)', { sidebarColor = sidebarColor }))

-- has to be required after theme is set up for highlighting
require('configure-trailing-whitespace')
