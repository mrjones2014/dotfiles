local M = {}

function M.default_commands()
  return {
    -- because sometimes I fat-finger it and run :Q instead of :q by accident
    {
      ':Q',
      ':q',
      description = 'Close window',
    },
    {
      ':CopyFilepath',
      function()
        require('my.utils').copy_to_clipboard(require('my.paths').relative_filepath())
      end,
      description = 'Copy current relative filepath to clipboard',
    },
    {
      ':CopyBranch',
      function()
        require('my.utils').copy_to_clipboard(require('my.utils').git_branch())
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
      ':BindLspKeymaps',
      function()
        require('legendary').bind_keymaps(require('my.keymap').lsp_keymaps(0))
      end,
      description = "Manually bind LSP keymaps in case they didn't get bound",
    },
    {
      ':OnlyBuffer',
      ':%bd|e#|bd#',
      description = 'Close all buffers except current',
    },
    {
      ':Icons',
      function()
        require('my.nerdfonticons').pick()
      end,
      description = 'Find NerdFont icons',
    },
    -- Neotest
    {
      ':Test',
      function()
        require('neotest').run.run()
      end,
      description = 'Run nearest test',
    },
    {
      ':TestFile',
      function()
        require('neotest').run.run(vim.fn.expand('%'))
      end,
      description = 'Run all tests in current file',
    },
    {
      ':TestStop',
      function()
        require('neotest').run.stop()
      end,
      description = 'Kill running tests',
    },
    {
      ':TestOpen',
      function()
        require('neotest').output.open({ enter = true })
      end,
      description = 'Open test output',
    },
    {
      ':TestSummary',
      function()
        require('neotest').summary.open()
      end,
    },
  }
end

function M.lsp_commands(bufnr, server_name)
  -- don't need to gate these since we aren't creating the actual commands
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

  if server_name == 'null-ls' and not (vim.api.nvim_buf_get_commands(0, {}) or {}).Format then
    table.insert(commands, 1, {
      ':Format',
      require('my.lsp.utils').format_document,
      description = 'Format the current document with LSP',
      opts = { buffer = bufnr },
    })
  end

  return commands
end

return M
