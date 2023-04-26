local conditions = require('heirline.conditions')

local M = {}

M.Align = { provider = '%=' }

M.DiagnosticSign = {
  {
    condition = function()
      return not conditions.lsp_attached or #vim.diagnostic.get(0) == 0
    end,
    provider = ' ',
  },
  {
    condition = function()
      return conditions.lsp_attached or #vim.diagnostic.get(0) > 0
    end,
    init = function(self)
      self.sign = nil
      self.has_sign = false
      local buf = vim.api.nvim_get_current_buf()
      local signs = vim.fn.sign_getplaced(buf, { group = '*', lnum = vim.v.lnum })[1]
      -- only show the highest severity sign
      if signs.signs[1] ~= nil and vim.startswith(signs.signs[1].group, 'vim.diagnostic') then
        self.has_sign = true
        self.sign = signs.signs[1]
      end
    end,
    provider = function(self)
      if self.has_sign then
        return require('my.lsp.icons')[self.sign.name]
      end
    end,
    hl = function(self)
      if self.has_sign then
        return self.sign.name
      end
    end,
  },
}

M.LineNumAndGitIndicator = {
  condition = function()
    local bt = vim.api.nvim_buf_get_option(0, 'buftype')
    return vim.v.virtnum == 0 and (bt == '' or not bt)
  end,
  provider = function()
    return string.format('%%=%s', vim.v.lnum)
  end,
  hl = {
    fg = 'gray',
  },
  {
    -- git diff indicators
    init = function(self)
      if conditions.is_git_repo() then
        self.sign = nil
        self.has_sign = false
        local buf = vim.api.nvim_get_current_buf()
        local signs = vim.fn.sign_getplaced(buf, { group = 'gitsigns_vimfn_signs_', lnum = vim.v.lnum })[1]
        if signs.signs[1] ~= nil and signs.signs and signs.signs[1] then
          self.has_sign = true
          self.sign = signs.signs[1]
          self.hlgroup = self.sign.name
        end
      end
    end,
    provider = ' ▏',
    hl = function(self)
      if self.has_sign then
        return self.hlgroup
      end
    end,
  },
}

return M
