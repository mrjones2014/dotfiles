return {
  'nvim-lualine/lualine.nvim',
  after = 'lighthaus.nvim',
  config = function()
    local lualine_theme = 'lighthaus_dark'

    local function is_file_open()
      return #(vim.fn.expand('%')) > 0
    end

    local mode_icons = {
      ['n'] = '🄽',
      ['no'] = '🄽',
      ['nov'] = '🄽',
      ['noV'] = '🄽',
      ['no'] = '🄽',
      ['niI'] = '🄽',
      ['niR'] = '🄽',
      ['niV'] = '🄽',
      ['v'] = '🅅',
      ['V'] = '🅅',
      [''] = '🅅',
      ['s'] = '🅂',
      ['S'] = '🅂',
      [''] = '🅂',
      ['i'] = '🄸',
      ['ic'] = '🄸',
      ['ix'] = '🄸',
      ['R'] = '🅁',
      ['Rc'] = '🅁',
      ['Rv'] = '🅁',
      ['Rx'] = '🅁',
      ['r'] = '🅁',
      ['rm'] = '🅁',
      ['r?'] = '🅁',
      ['c'] = '🄲',
      ['cv'] = '🄲',
      ['ce'] = '🄲',
      ['!'] = '🅃',
      ['t'] = '🅃',
    }

    local function get_mode()
      local mode = vim.api.nvim_get_mode().mode
      if mode_icons[mode] == nil then
        return mode
      end

      return mode_icons[mode] .. ' '
    end

    local function filepath()
      return require('paths').relative_filepath()
    end

    local sections = {
      lualine_a = { get_mode },
      lualine_b = {},
      lualine_c = {
        filepath,
        {
          'diagnostics',
          sources = { 'nvim_diagnostic' },
          sections = { 'error', 'warn', 'info', 'hint' },
          always_visible = is_file_open,
          update_in_insert = true,
        },
      },
      lualine_x = {},
      lualine_y = {},
      lualine_z = { 'progress' },
    }

    require('lualine').setup({
      options = {
        theme = lualine_theme,
        disabled_filetypes = { 'NvimTree', 'term', 'terminal', 'TelescopePrompt', 'packer' },
      },
      sections = sections,
      inactive_sections = sections,
      extensions = { 'nvim-tree' },
    })
  end,
}
