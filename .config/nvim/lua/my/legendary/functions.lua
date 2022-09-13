local M = {}

function M.default_functions()
  return {
    {
      function()
        require('my.utils').copy_to_clipboard(require('my.paths').relative_filepath())
      end,
      description = 'Copy current relative filepath to clipboard',
    },
    {
      function()
        require('my.utils').copy_to_clipboard(require('my.utils').git_branch())
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
