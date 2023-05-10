local M = {}

function M.default_commands()
  return {
    -- because sometimes I fat-finger it and run :Q instead of :q by accident
    { ':Q', ':q' },
    { ':Qa', ':qa' },
    { ':W', ':w' },
    { ':Wq', ':wq' },
    { ':Wqa', ':wq' },
    { ':Wa', ':wa' },
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
      function()
        require('iconpicker').pick(function(icon)
          if not icon or #icon == 0 then
            return
          end

          Clipboard.copy(icon)
          vim.notify('Copied icon to clipboard.', vim.log.levels.INFO)
        end)
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
    {
      ':Dismiss',
      function()
        require('notify').dismiss({ pending = true, silent = true })
      end,
      description = 'Dismiss notifications',
    },

    -- keymaps come from Comment.nvim
    {
      ':Comment',
      {
        n = 'gcc',
        v = 'gc',
      },
      description = 'Toggle comment',
    },
    {
      ':Glow',
      description = 'Preview markdown with glow',
      filters = { filetype = 'markdown' },
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
    commands = TblUtils.join_lists(commands, {
      {
        ':Test',
        h.lazy_required_fn('neotest', 'run.run'),
        description = 'Run nearest test',
        opts = { buffer = bufnr },
      },
      {
        ':TestFile',
        function()
          require('neotest').run.run(vim.fn.expand('%'))
        end,
        description = 'Run all tests in current file',
        opts = { buffer = bufnr },
      },
      {
        ':TestStop',
        h.lazy_required_fn('neotest', 'run.stop'),
        description = 'Kill running tests',
        opts = { buffer = bufnr },
      },
      {
        ':TestOpen',
        h.lazy_required_fn('neotest', 'output.open', { enter = true }),
        description = 'Open test output',
        opts = { buffer = bufnr },
      },
      {
        ':TestSummary',
        h.lazy_required_fn('neotest', 'summary.open'),
        description = 'Show a test summary sidebar',
        opts = { buffer = bufnr },
      },
    })
  end

  if vim.api.nvim_buf_get_option(bufnr, 'filetype') == 'rust' then
    table.insert(commands, {
      ':CargoToml',
      function()
        local cargo_toml = vim.fs.find('Cargo.toml', {
          upward = true,
          stop = vim.loop.cwd(),
          path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
        })
        if #cargo_toml == 0 then
          vim.notify("Couldn't find Cargo.toml in cwd")
          return
        end

        vim.cmd.edit(cargo_toml[1])
      end,
      description = 'Open the `Cargo.toml` that is closest to the current file in the tree.',
      opts = { buffer = bufnr },
    })
  end

  return {
    itemgroup = 'LSP',
    commands = commands,
  }
end

return M
