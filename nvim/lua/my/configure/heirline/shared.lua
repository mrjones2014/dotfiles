local utils = require('heirline.utils')

local M = {}

function M.FileIcon(bg_color)
  return {
    init = function(self)
      local ft = vim.api.nvim_buf_get_option(0, 'filetype')
      local icon, hl = require('nvim-web-devicons').get_icon_by_filetype(ft)
      self.icon = icon
      self.icon_hl = hl
      self.bufname = vim.api.nvim_buf_get_name(0)
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

M.FilePath = {
  init = function(self)
    self.bufname = vim.api.nvim_buf_get_name(0)
  end,
  condition = function(self)
    return self.bufname ~= '' and not vim.startswith(self.bufname, 'component://')
  end,
  provider = function(self)
    return Path.relative(self.bufname)
  end,
}

local icons = require('my.lsp.icons')
local severities_order = { 'Hint', 'Information', 'Warning', 'Error' }
local severity_hl = { Hint = 'Hint', Information = 'Info', Warning = 'Warn', Error = 'Error' }
local severities = {
  Hint = vim.diagnostic.severity.HINT,
  Information = vim.diagnostic.severity.INFO,
  Warning = vim.diagnostic.severity.WARN,
  Error = vim.diagnostic.severity.ERROR,
}
local diagnostics_base = {
  init = function(self)
    local all_diagnostics = vim.diagnostic.get(0)
    for key, severity in pairs(severities) do
      self[key] = #vim.tbl_filter(function(d)
        return d.severity == severity
      end, all_diagnostics)
    end
  end,
}

function M.Diagnostics(is_winbar, bg)
  bg = bg or 'bg_statusline'
  return utils.insert(
    diagnostics_base,
    unpack(vim.tbl_map(function(severity)
      local component = {
        provider = function(self)
          return string.format('%s%s ', icons[severity], self[severity])
        end,
        hl = function()
          return { fg = utils.get_highlight(string.format('DiagnosticSign%s', severity_hl[severity])).fg, bg = bg }
        end,
      }
      if is_winbar then
        component.condition = function(self)
          return self[severity] > 0
        end
      end
      return component
    end, severities_order))
  )
end

return M
