local conditions = require('heirline.conditions')
local utils = require('heirline.utils')

local M = {}

M.LspDiagIcon = {
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
      if signs.signs[1] ~= nil and vim.startswith(signs.signs[1].group, 'vim.diagnostic') then
        self.has_sign = true
        self.sign = signs.signs[1]
      end
    end,
    -- XXX: This throws an error, even though it works in other components.
    -- update = 'DiagnosticChanged'
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

M.GitIndicator = {
  condition = conditions.is_git_repo,
  provider = ' ▏',
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
  hl = function(self)
    if self.has_sign then
      return self.hlgroup
    end
  end,
}

M.LineNo = {
  condition = function()
    local bt = vim.api.nvim_buf_get_option(0, 'buftype')
    return vim.v.virtnum == 0 and (bt == '' or not bt)
  end,
  init = function(self)
    local lines = vim.api.nvim_buf_line_count(0)
    self.padding = tostring(lines):len()
  end,
  provider = function(self)
    if vim.opt.relativenumber then
      return string.format('%-' .. self.padding .. 'd', vim.v.lnum)
    else
      return string.format('%' .. self.padding .. 'd', vim.v.relnum)
    end
  end,
}

return M
