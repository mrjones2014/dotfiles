local utils = require('heirline.utils')

local M = {}

function M.FileIcon(bg_color)
  return {
    init = function(self)
      self.bufname = vim.api.nvim_buf_get_name(0)
      local icon, hl = require('nvim-web-devicons').get_icon(self.bufname, vim.fn.fnamemodify(self.bufname, ':e'))
      self.icon = icon
      self.icon_hl = hl
    end,
    provider = ' ',
    hl = { bg = bg_color },
    {
      condition = function(self)
        return self.icon ~= nil
          and self.icon_hl ~= nil
          and require('my.configure.heirline.conditions').should_show_filename(self.bufname)
      end,
      provider = function(self)
        return self.icon
      end,
      hl = function(self)
        return { fg = utils.get_highlight(self.icon_hl).fg, bg = bg_color }
      end,
    },
  }
end

local diagnostics_order = {
  vim.diagnostic.severity.HINT,
  vim.diagnostic.severity.INFO,
  vim.diagnostic.severity.WARN,
  vim.diagnostic.severity.ERROR,
}
local severity_name = {
  [vim.diagnostic.severity.HINT] = 'Hint',
  [vim.diagnostic.severity.INFO] = 'Info',
  [vim.diagnostic.severity.WARN] = 'Warn',
  [vim.diagnostic.severity.ERROR] = 'Error',
}
local diagnostics_base = {
  update = { 'DiagnosticChanged', 'BufEnter' },
  init = function(self)
    self.counts = vim.diagnostic.count(0)
  end,
}

function M.Diagnostics(is_winbar, bg)
  bg = bg or 'surface0'
  return utils.insert(
    diagnostics_base,
    unpack(vim
      .iter(diagnostics_order)
      :map(function(severity)
        local component = {
          provider = function(self)
            local sign = vim.diagnostic.config().signs.text[severity]
            return string.format('%s%s ', sign, self.counts[severity] or 0)
          end,
          hl = function()
            return { fg = utils.get_highlight(string.format('DiagnosticSign%s', severity_name[severity])).fg, bg = bg }
          end,
        }
        if is_winbar then
          component.condition = function(self)
            return (self.counts[severity] or 0) > 0
          end
        end
        return component
      end)
      :totable())
  )
end

M.Trunc = {
  provider = '%<',
}

return M
