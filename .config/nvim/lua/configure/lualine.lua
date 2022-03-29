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

    local sections = {
      lualine_a = { get_mode },
      lualine_b = { 'branch' },
      lualine_c = {
        { 'filename', shorting_target = 0, path = 1 },
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
      lualine_z = { 'location', 'progress' },
    }

    local buffer_line = {
      lualine_a = {},
      lualine_b = { 'buffers' },
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    }

    -- currently using luailne for both tabline and statusline
    -- until this PR is merged and I can have buffer list per-window
    -- at the top: https://github.com/neovim/neovim/pull/17336
    -- when that's merged we can use the global statusline again
    require('lualine').setup({
      options = {
        globalstatus = false,
        theme = lualine_theme,
      },
      sections = buffer_line,
      inactive_sections = buffer_line,
      tabline = sections,
      extensions = { 'nvim-tree', 'quickfix' },
    })
  end,
}
