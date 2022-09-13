return {
  'feline-nvim/feline.nvim',
  after = 'onedarkpro.nvim',
  config = function()
    local colors = require('onedarkpro').get_colors('onedark_dark')
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
    local mode_colors = {
      ['NORMAL'] = colors.green,
      ['OP'] = colors.green,
      ['INSERT'] = colors.blue,
      ['VISUAL'] = colors.yellow,
      ['LINES'] = colors.yellow,
      ['BLOCK'] = colors.yellow,
      ['REPLACE'] = colors.purple,
      ['V-REPLACE'] = colors.purple,
      ['ENTER'] = colors.cyan,
      ['MORE'] = colors.cyan,
      ['SELECT'] = colors.orange,
      ['COMMAND'] = colors.blue,
      ['SHELL'] = colors.green,
      ['TERM'] = colors.green,
      ['NONE'] = colors.yellow,
    }

    local diagnostics_icons = require('my.lsp.icons')
    local diagnostics_ui = {
      [vim.diagnostic.severity.HINT] = { icon = diagnostics_icons.Hint, color = colors.cyan },
      [vim.diagnostic.severity.INFO] = { icon = diagnostics_icons.Info, color = colors.blue },
      [vim.diagnostic.severity.WARN] = { icon = diagnostics_icons.Warning, color = colors.yellow },
      [vim.diagnostic.severity.ERROR] = { icon = diagnostics_icons.Error, color = colors.red },
    }
    local diagnostics_order = {
      vim.diagnostic.severity.HINT,
      vim.diagnostic.severity.INFO,
      vim.diagnostic.severity.WARN,
      vim.diagnostic.severity.ERROR,
    }

    local components = {
      mode = {
        left_sep = 'block',
        provider = function()
          local mode = vim.api.nvim_get_mode().mode
          return mode_icons[mode] .. ' '
        end,
        hl = function()
          return {
            fg = colors.bg_statusline,
            bg = require('feline.providers.vi_mode').get_mode_color(),
            bold = true,
          }
        end,
        right_sep = {
          str = 'right_rounded',
          hl = function()
            if vim.b.gitsigns_head then
              return {
                fg = require('feline.providers.vi_mode').get_mode_color(),
                bg = colors.fg_gutter,
              }
            end
          end,
        },
      },
      branch = {
        left_sep = 'block',
        provider = 'git_branch',
        icon = ' ',
        hl = {
          bg = colors.fg_gutter,
          fg = colors.green,
        },
        right_sep = 'right_rounded',
      },
      file_info = {
        left_sep = 'block',
        provider = {
          name = 'file_info',
          opts = {
            file_readonly_icon = '',
            type = 'relative',
          },
        },
        right_sep = 'right_rounded',
      },
      op = {
        left_sep = 'left_rounded',
        provider = function()
          return require('op.statusline').component()
        end,
        hl = {
          bg = colors.blue,
          fg = colors.gray,
        },
        right_sep = 'block',
      },
      buffers = {
        provider = require('my.configure.feline.buffers'),
        hl = {
          bg = colors.bg_statusline,
          fg = colors.fg,
        },
      },
      diagnostics = function(severity)
        local ui = diagnostics_ui[severity]
        return {
          left_sep = severity == diagnostics_order[1] and {
            str = 'left_rounded',
            hl = {
              bg = colors.blue,
              fg = colors.bg_statusline,
            },
          } or nil,
          provider = function()
            return tostring(#vim.tbl_filter(function(diag)
              return diag.severity == severity
            end, vim.diagnostic.get(0)))
          end,
          icon = ui.icon,
          hl = {
            fg = ui.color,
            bg = colors.bg_statusline,
          },
          right_sep = diagnostics_order[#diagnostics_order] and 'block' or nil,
        }
      end,
    }

    local statusline_components = {
      { components.mode, components.branch, components.file_info },
      {},
      vim.list_extend({ components.op }, vim.tbl_map(components.diagnostics, diagnostics_order)),
    }

    local winbar_components = {
      { components.buffers },
      {},
      {},
    }

    require('feline').setup({
      default_bg = colors.bg_statusline,
      default_fg = colors.bg_statusline,
      components = {
        active = statusline_components,
        inactive = statusline_components,
      },
      vi_mode_colors = mode_colors,
    })
    require('feline').winbar.setup({
      default_bg = colors.bg_statusline,
      default_fg = colors.bg_statusline,
      components = {
        active = winbar_components,
        inactive = winbar_components,
      },
    })
  end,
}
