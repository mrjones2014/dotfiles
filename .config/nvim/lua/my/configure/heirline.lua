return {
  'rebelot/heirline.nvim',
  event = 'BufRead',
  config = function()
    local conditions = require('heirline.conditions')
    local utils = require('heirline.utils')

    local components = {}

    components.LspDiagIcon = {
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

    local GitHighlight = {
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

    components.GitIndicator = utils.insert(GitHighlight, {
      condition = conditions.is_git_repo,
      provider = ' ▏',
    })

    components.LineNo = utils.insert(GitHighlight, {
      condition = function()
        return vim.v.virtnum == 0
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
    })

    components.Align = { provider = '%=' }

    require('heirline').setup({
      statuscolumn = {
        components.LspDiagIcon,
        components.Align,
        components.LineNo,
        components.GitIndicator,
        components.Space,
      },
    })
  end,
}
