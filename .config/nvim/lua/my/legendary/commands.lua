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
        require('legendary').keymaps(require('my.legendary.keymap').lsp_keymaps(0))
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
      require('my.nerdfonticons').pick,
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
    {
      ':Dismiss',
      function()
        require('notify').dismiss({ pending = true, silent = true })
      end,
      description = 'Dismiss notifications',
    },
    {
      ':PackerRecompile',
      function()
        local path = require('my.plugins').compile_path
        vim.fn.jobstart({ 'rm', path }, { detach = true })
        ---@diagnostic disable
        vim.defer_fn(function()
          vim.cmd('PackerCompile')
        end, 1)
        ---@diagnostic enable
      end,
      description = 'Delete packer_compiled.lua',
    },
  }
end

function M.lsp_commands(bufnr, server_name)
  local h = require('legendary.toolbox')
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
    table.insert_all(commands, {
      ':Test',
      h.lazy_required_fn('neotest', 'run.run'),
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
      h.lazy_required_fn('neotest', 'run.stop'),
      description = 'Kill running tests',
      opts = { buffer = bufnr },
    }, {
      ':TestOpen',
      h.lazy_required_fn('neotest', 'output.open', { enter = true }),
      description = 'Open test output',
      opts = { buffer = bufnr },
    }, {
      ':TestSummary',
      h.lazy_required_fn('neotest', 'summary.open'),
      opts = { buffer = bufnr },
    })
  end

  return commands
end

return M
