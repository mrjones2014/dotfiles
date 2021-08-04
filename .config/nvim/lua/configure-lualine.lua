local icons = require('nvim-nonicons')

local function filepath()
  local path = vim.fn.expand('%')
  if vim.fn.winwidth(0) <= 84 then
    path = vim.fn.pathshorten(path)
  end
  return icons.get('file') .. '  ' .. path
end

local modeIcons = {
  ['n']    = icons.get('vim-normal-mode'),
  ['no']   = icons.get('vim-normal-mode'),
  ['nov']  = icons.get('vim-normal-mode'),
  ['noV']  = icons.get('vim-normal-mode'),
  ['no'] = icons.get('vim-normal-mode'),
  ['niI']  = icons.get('vim-normal-mode'),
  ['niR']  = icons.get('vim-normal-mode'),
  ['niV']  = icons.get('vim-normal-mode'),
  ['v']    = icons.get('vim-visual-mode'),
  ['V']    = icons.get('vim-visual-mode'),
  ['']   = icons.get('vim-visual-mode'),
  ['s']    = icons.get('vim-select-mode'),
  ['S']    = icons.get('vim-select-mode'),
  ['']   = icons.get('vim-select-mode'),
  ['i']    = icons.get('vim-insert-mode'),
  ['ic']   = icons.get('vim-insert-mode'),
  ['ix']   = icons.get('vim-insert-mode'),
  ['R']    = icons.get('vim-replace-mode'),
  ['Rc']   = icons.get('vim-replace-mode'),
  ['Rv']   = icons.get('vim-replace-mode'),
  ['Rx']   = icons.get('vim-replace-mode'),
  ['c']    = icons.get('vim-command-mode'),
  ['cv']   = icons.get('vim-command-mode'),
  ['ce']   = icons.get('vim-command-mode'),
  ['r']    = icons.get('vim-replace-mode'),
  ['rm']   = icons.get('vim-replace-mode'),
  ['r?']   = icons.get('vim-replace-mode'),
  ['!']    = icons.get('vim-terminal-mode'),
  ['t']    = icons.get('vim-terminal-mode'),
}

local function getMode()
  local mode = vim.api.nvim_get_mode().mode
  if modeIcons[mode] == nil then
    return mode
  end

  return modeIcons[mode] .. ' '
end

require('lualine').setup({
  options = {
    theme = 'tokyonight',
    disabled_filetypes = {'NvimTree', 'term', 'terminal', 'fzf'},
  },
  sections = {
    lualine_a = {getMode},
    lualine_b = {'branch'},
    lualine_c = {{'diagnostics', sources = {'nvim_lsp'}, sections = {'error', 'warn', 'info', 'hint'}}, filepath},
    lualine_x = {'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
  inactive_sections = {
    lualine_a = {getMode},
    lualine_b = {'branch'},
    lualine_c = {{'diagnostics', sources = {'nvim_lsp'}, sections = {'error', 'warn', 'info', 'hint'}}, filepath},
    lualine_x = {'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
  extensions = {'nvim-tree'},
})
