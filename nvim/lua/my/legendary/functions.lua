local clipboard = require('my.utils.clipboard')
local path = require('my.utils.path')

local M = {}

function M.default_functions()
  return {
    {
      function()
        clipboard.copy(vim.fn.simplify(path.relative(vim.fn.expand('%') --[[@as string]])))
      end,
      description = 'Copy current relative filepath to clipboard',
    },
    {
      function()
        if vim.g.gitsigns_head or vim.b.gitsigns_head then
          clipboard.copy(vim.g.gitsigns_head or vim.b.gitsigns_head)
        else
          vim.notify('Not in a git repo.')
        end
      end,
      description = 'Copy current git branch name to clipboard',
    },
  }
end

return M
