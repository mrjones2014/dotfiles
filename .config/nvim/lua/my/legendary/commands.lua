local M = {}

function M.default_commands()
  return {
    -- because sometimes I fat-finger it and run :Q instead of :q by accident
    { ':Q', ':q' },
    { ':Qa', ':qa' },
    { ':Wq', ':wq' },
    { ':Wqa', ':wq' },
    {
      ':BindLspKeymaps',
      function()
        require('legendary').bind_keymaps(require('my.legendary.keymap').lsp_keymaps(0))
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
    {
      ':H',
      function()
        local cursor_word = vim.fn.expand('<cword>')
        vim.cmd.help(cursor_word)
      end,
      description = 'Search help for word under cursor',
    },
    {
      ':OpenFileDir',
      function()
        local dir = vim.fn.expand('%:p:h')
        vim.cmd(string.format('!open %s', dir))
      end,
      description = 'Open directory containing current file',
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
    table.insert(commands, {
      ':Format',
      require('my.lsp.utils').format_document,
      description = 'Format the current document with LSP',
      opts = { buffer = bufnr },
    })
  end

  if not (vim.api.nvim_buf_get_commands(0, {}) or {}).Test then
    -- Neotest
    require('my.utils').insert_all(commands, {
      ':Test',
      function()
        require('neotest').run.run()
      end,
      description = 'Run nearest test',
      opts = { buffer = bufnr },
    }, {
      ':TestFile',
      function()
        require('neotest').run.run(vim.fn.expand('%'))
      end,
      description = 'Run all tests in current file',
      opts = { buffer = bufnr },
    }, {
      ':TestStop',
      function()
        require('neotest').run.stop()
      end,
      description = 'Kill running tests',
      opts = { buffer = bufnr },
    }, {
      ':TestOpen',
      function()
        require('neotest').output.open({ enter = true })
      end,
      description = 'Open test output',
      opts = { buffer = bufnr },
    }, {
      ':TestSummary',
      function()
        require('neotest').summary.open()
      end,
      opts = { buffer = bufnr },
    })
  end

  return commands
end

return M
