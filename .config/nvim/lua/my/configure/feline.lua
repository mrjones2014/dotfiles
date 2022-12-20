return {
  'feline-nvim/feline.nvim',
  event = 'VimEnter',
  config = function()
    vim.opt.laststatus = 3
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

    local function unsaved_changes()
      local unsaved_buffers = vim.tbl_filter(function(buf)
        return vim.api.nvim_buf_get_option(buf, 'modifiable') and vim.api.nvim_buf_get_option(buf, 'modified')
      end, vim.api.nvim_list_bufs())
      if #vim.fn.expand('%') == 0 or #unsaved_buffers == 0 then
        return ''
      end
      return string.format(' %s unsaved file%s ', #unsaved_buffers, #unsaved_buffers > 1 and 's' or '')
    end

    local function is_current_buf()
      return vim.api.nvim_get_current_buf() == tonumber(vim.g.actual_curbuf)
    end

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
        enabled = function()
          return not not vim.b.gitsigns_head
        end,
      },
      file_info = {
        left_sep = 'block',
        provider = {
          name = 'file_info',
          opts = {
            file_readonly_icon = ' ',
            type = 'relative',
          },
        },
        right_sep = 'right_rounded',
        enabled = function()
          return vim.api.nvim_buf_get_name(tonumber(vim.g.actual_curbuf) or 0) ~= ''
        end,
      },
      file_info_short = {
        left_sep = 'block',
        provider = {
          name = 'file_info',
          opts = {
            file_readonly_icon = ' ',
            type = 'unique',
          },
        },
        hl = function()
          return {
            bg = is_current_buf() and colors.bg or colors.dark_gray,
          }
        end,
        right_sep = {
          str = '  ┃',
          hl = function()
            return {
              fg = colors.white,
              bg = is_current_buf() and colors.bg or colors.dark_gray,
            }
          end,
        },
        enabled = function()
          return vim.api.nvim_buf_get_name(tonumber(vim.g.actual_curbuf) or 0) ~= ''
        end,
      },
      op = {
        left_sep = {
          str = 'left_rounded',
          hl = function()
            if #unsaved_changes() > 0 then
              return {
                fg = colors.blue,
                bg = colors.yellow,
              }
            else
              return {
                fg = colors.blue,
              }
            end
          end,
        },
        provider = function()
          return require('op.statusline').component()
        end,
        hl = {
          bg = colors.blue,
          fg = colors.gray,
        },
        right_sep = 'block',
      },
      unsaved_changes = {
        left_sep = 'left_rounded',
        provider = unsaved_changes,
        icon = '',
        hl = {
          bg = colors.yellow,
          fg = colors.black,
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
          right_sep = 'block',
        }
      end,
      winbar_spacer = {
        provider = function()
          return ''
        end,
        right_sep = {
          str = ' ',
          hl = {
            fg = colors.darker_gray,
            bg = colors.darker_gray,
          },
        },
      },
    }

    local statusline_components = {
      { components.mode, components.branch, components.file_info },
      {},
      ---@diagnostic disable -- optional parameters omitted
      vim.list_extend(
        { components.unsaved_changes, components.op },
        vim.tbl_map(components.diagnostics, diagnostics_order)
      ),
      ---@diagnostic enable
    }

    local winbar_components = {
      { components.file_info_short, components.winbar_spacer },
      {},
      {},
    }

    local shared_config = {
      default_bg = colors.bg_statusline,
      default_fg = colors.bg_statusline,
      vi_mode_colors = mode_colors,
    }

    require('feline').setup(vim.tbl_deep_extend('force', shared_config, {
      components = {
        active = statusline_components,
        inactive = statusline_components,
      },
    }))

    require('feline').winbar.setup(vim.tbl_deep_extend('force', shared_config, {
      components = {
        active = winbar_components,
        inactive = winbar_components,
      },
    }))
  end,
}
