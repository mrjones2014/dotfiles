return {
  'nvim-lualine/lualine.nvim',
  after = 'onedarkpro.nvim',
  config = function()
    local lualine_theme = 'onedarkpro'

    local function is_file_open()
      return #(vim.fn.expand('%')) > 0
    end

    local mode_icons = {
      ['n'] = '🅽',
      ['no'] = '🅽',
      ['nov'] = '🅽',
      ['noV'] = '🅽',
      ['no'] = '🅽',
      ['niI'] = '🅽',
      ['niR'] = '🅽',
      ['niV'] = '🅽',
      ['v'] = '🆅',
      ['V'] = '🆅',
      [''] = '🆅',
      ['s'] = '🆂',
      ['S'] = '🆂',
      [''] = '🆂',
      ['i'] = '🅸',
      ['ic'] = '🅸',
      ['ix'] = '🅸',
      ['R'] = '🆁',
      ['Rc'] = '🆁',
      ['Rv'] = '🆁',
      ['Rx'] = '🆁',
      ['r'] = '🆁',
      ['rm'] = '🆁',
      ['r?'] = '🆁',
      ['c'] = '🅲',
      ['cv'] = '🅲',
      ['ce'] = '🅲',
      ['!'] = '🆃',
      ['t'] = '🆃',
      ['nt'] = '🆃',
    }

    local function get_mode()
      local mode = vim.api.nvim_get_mode().mode
      if mode_icons[mode] == nil then
        return mode
      end

      return mode_icons[mode] .. ' '
    end

    local function filepath()
      return require('my.paths').relative_filepath()
    end

    local function lsp_progress()
      if not rawget(vim, 'lsp') then
        return ''
      end

      local lsp_progress_msg = vim.lsp.util.get_progress_messages()[1]

      if vim.o.columns < 120 or not lsp_progress_msg then
        return ''
      end

      local msg = lsp_progress_msg.message or ''
      local percentage = lsp_progress_msg.percentage or 0
      local title = lsp_progress_msg.title or ''
      local spinners = { '', '' }
      local ms = vim.loop.hrtime() / 1000000
      local frame = math.floor(ms / 120) % #spinners
      local content = string.format(' %%<%s %s %s (%s%%%%) ', spinners[frame + 1], title, msg, percentage)

      return content or ''
    end

    local function sep_right()
      return ''
    end

    local sections = {
      lualine_a = { get_mode },
      lualine_b = { { 'branch', icon = '' } },
      lualine_c = { filepath, '%=', lsp_progress },
      lualine_x = {
        require('op.statusline').component,
        sep_right,
        {
          'diagnostics',
          sources = { 'nvim_diagnostic' },
          sections = { 'error', 'warn', 'info', 'hint' },
          always_visible = is_file_open,
          update_in_insert = true,
        },
      },
      lualine_y = {},
      lualine_z = { 'location', sep_right, 'progress' },
    }

    local winbar_inactive_color = require('onedarkpro.utils').lighten('#000000', 0.01, '#212021')
    local winbar_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        {
          'buffers',
          symbols = {
            alternate_file = '',
          },
          section_separators = {
            left = '│',
            right = '│',
          },
          component_separators = {
            left = '│',
            right = '│',
          },
          buffers_color = {
            active = { bg = '#000000' },
            inactive = { bg = winbar_inactive_color },
          },
        },
        { '%=', color = { bg = winbar_inactive_color } },
      },
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    }

    require('lualine').setup({
      options = {
        globalstatus = true,
        theme = lualine_theme,
        component_separators = '',
      },
      sections = sections,
      inactive_sections = sections,
      winbar = winbar_sections,
      inactive_winbar = winbar_sections,
      extensions = { 'nvim-tree', 'quickfix' },
    })
  end,
}
