local utils = require('heirline.utils')

local M = {}

M.Align = { provider = '%=', hl = { bg = 'surface0' } }

function M.FileIcon(bg_color)
  return {
    init = function(self)
      self.bufname = vim.api.nvim_buf_get_name(0)
      self.ft = vim.fn.fnamemodify(self.bufname, ':e')
      if self.ft == '' or self.ft == nil then
        self.ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
      end
      local icon, hl = require('nvim-web-devicons').get_icon(self.bufname, self.ft, { default = true })
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

M.Trunc = {
  provider = '%<',
}

return M
