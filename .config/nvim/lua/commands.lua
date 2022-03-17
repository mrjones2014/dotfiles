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
    {
      ':LegendaryScratch',
      description = 'Open a Lua scratchpad buffer',
    },
    {
      ':LegendaryEvalBuf',
      description = 'Eval buffer as Lua',
    },
    {
      ':LegendaryEvalLine',
      description = 'Eval current line as Lua',
    },
    {
      ':LegendaryEvalLines',
      description = 'Eval selected lines as Lua',
    },
  }
end

function M.lsp_commands(bufnr, server_name)
  local commands = {
    {
      ':LspRestart',
      description = 'Restart any attached LSP clients',
      opts = { buffer = bufnr },
    },
    {
      ':LspStart',
      description = 'Start the LSP client manually',
      opts = { buffer = bufnr },
    },
    {
      ':LspInfo',
      description = 'Show attached LSP clients',
      opts = { buffer = bufnr },
    },
  }

  if server_name == 'null-ls' then
    table.insert(commands, 1, {
      ':Format',
      require('lsp.utils').format_document,
      description = 'Format the current document with LSP',
      opts = { buffer = bufnr },
    })
  end

  return commands
end

return M
