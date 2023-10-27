local M = {}

function M.default_functions()
  return {
    {
      function()
        Clipboard.copy(vim.fn.simplify(Path.relative(vim.fn.expand('%') --[[@as string]])))
      end,
      description = 'Copy current relative filepath to clipboard',
    },
    {
      function()
        if vim.g.gitsigns_head or vim.b.gitsigns_head then
          Clipboard.copy(vim.g.gitsigns_head or vim.b.gitsigns_head)
        else
          vim.notify('Not in a git repo.')
        end
      end,
      description = 'Copy current git branch name to clipboard',
    },
  }
end

return M
