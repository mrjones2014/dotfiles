local M = {}

function M.default_commands()
  return {
    {
      ':CopyFilepath',
      function()
        require('utils').copy_to_clipboard(require('paths').relative_filepath())
      end,
      description = 'Copy current relative filepath to clipboard',
    },
    {
      ':CopyBranch',
      function()
        require('utils').copy_to_clipboard(require('utils').git_branch())
      end,
      description = 'Copy current git branch name to clipboard',
    },
    {
      ':Uuid',
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

function M.lsp_commands()
  return {
    {
      ':Format',
      M.format_document,
      description = 'Format the current document with LSP',
    },
    {
      ':LspRestart',
      description = 'Restart any attached LSP clients',
    },
    {
      ':LspStart',
      description = 'Start the LSP client manually',
    },
    {
      ':LspInfo',
      description = 'Show attached LSP clients',
    },
  }
end

return M
