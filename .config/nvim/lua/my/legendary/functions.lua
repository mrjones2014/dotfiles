local M = {}

function M.default_functions()
  return {
    {
      function()
        Clipboard.copy(vim.fn.simplify(Path.relative(vim.fn.expand('%'))))
      end,
      description = 'Copy current relative filepath to clipboard',
    },
    {
      function()
        if vim.b.gitsigns_head then
          Clipboard.copy(vim.b.gitsigns_head)
        else
          vim.notify('Not in a git repo.')
        end
      end,
      description = 'Copy current git branch name to clipboard',
    },
    {
      function()
        local uuid = vim.fn.system('uuidgen'):gsub('\n', ''):lower()
        local line = vim.fn.getline('.')
        vim.schedule(function()
          vim.fn.setline('.', vim.fn.strpart(line, 0, vim.fn.col('.')) .. uuid .. vim.fn.strpart(line, vim.fn.col('.')))
        end)
      end,
      description = 'Generate a UUID and insert it into the buffer',
    },
  }
end

return M
