return {
  'mrjones2014/lualine.nvim',
  config = function()
    local lualine_theme = 'github'

    local icons = require('nvim-nonicons')

    local function is_file_open()
      return #(vim.fn.expand('%')) > 0
    end

    local function filepath()
      local path = vim.fn.expand('%')
      if vim.fn.winwidth(0) <= 84 then
        path = vim.fn.pathshorten(path)
      end

      if not path or #path == 0 then
        return ''
      end

      local icon = require('nvim-web-devicons').get_icon(path)
      return icon .. '  ' .. path
    end

    local mode_icons = {
      ['n'] = icons.get('vim-normal-mode'),
      ['no'] = icons.get('vim-normal-mode'),
      ['nov'] = icons.get('vim-normal-mode'),
      ['noV'] = icons.get('vim-normal-mode'),
      ['no'] = icons.get('vim-normal-mode'),
      ['niI'] = icons.get('vim-normal-mode'),
      ['niR'] = icons.get('vim-normal-mode'),
      ['niV'] = icons.get('vim-normal-mode'),
      ['v'] = icons.get('vim-visual-mode'),
      ['V'] = icons.get('vim-visual-mode'),
      [''] = icons.get('vim-visual-mode'),
      ['s'] = icons.get('vim-select-mode'),
      ['S'] = icons.get('vim-select-mode'),
      [''] = icons.get('vim-select-mode'),
      ['i'] = icons.get('vim-insert-mode'),
      ['ic'] = icons.get('vim-insert-mode'),
      ['ix'] = icons.get('vim-insert-mode'),
      ['R'] = icons.get('vim-replace-mode'),
      ['Rc'] = icons.get('vim-replace-mode'),
      ['Rv'] = icons.get('vim-replace-mode'),
      ['Rx'] = icons.get('vim-replace-mode'),
      ['c'] = icons.get('vim-command-mode'),
      ['cv'] = icons.get('vim-command-mode'),
      ['ce'] = icons.get('vim-command-mode'),
      ['r'] = icons.get('vim-replace-mode'),
      ['rm'] = icons.get('vim-replace-mode'),
      ['r?'] = icons.get('vim-replace-mode'),
      ['!'] = icons.get('terminal'),
      ['t'] = icons.get('terminal'),
    }

    local function get_mode()
      local mode = vim.api.nvim_get_mode().mode
      if mode_icons[mode] == nil then
        return mode
      end

      return mode_icons[mode] .. ' '
    end

    require('lualine').setup({
      options = {
        theme = lualine_theme,
        disabled_filetypes = { 'NvimTree', 'term', 'terminal', 'TelescopePrompt' },
      },
      sections = {
        lualine_a = { get_mode },
        lualine_b = { { 'branch', icon = icons.get('git-branch') } },
        lualine_c = {
          filepath,
          {
            'diagnostics',
            sources = { 'nvim_lsp' },
            sections = { 'error', 'warn', 'info', 'hint' },
            visible = is_file_open,
          },
        },
        lualine_x = { 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {},
      extensions = { 'nvim-tree' },
    })
  end,
}
