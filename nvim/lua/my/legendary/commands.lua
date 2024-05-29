local clipboard = require('my.utils.clipboard')

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

          clipboard.copy(icon)
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
      ':Plugins',
      function()
        local plugin_shorthands = vim.iter(require('lazy').plugins()):map(function(plugin)
          return plugin[1]
        end)
        vim.ui.select(plugin_shorthands, { prompt = 'Select Plugin' }, function(selected)
          if not selected then
            return
          end

          vim.ui.open(selected)
        end)
      end,
      description = 'Search installed plugins and open the repo in browser',
    },
  }
end

function M.lsp_commands(bufnr)
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

  if not (vim.api.nvim_buf_get_commands(0, {}) or {}).Format then
    vim.list_extend(commands, {
      {
        ':Format',
        function()
          require('conform').format({ async = true, lsp_fallback = true })
        end,
        description = 'Format the current document with LSP',
        opts = { buffer = bufnr },
      },
      {
        ':DisableFormatting',
        function()
          require('my.utils.lsp').toggle_formatting_enabled(false)
        end,
        description = 'Disable LSP formatting',
        opts = { buffer = bufnr },
      },
      {
        ':EnableFormatting',
        function()
          require('my.utils.lsp').toggle_formatting_enabled(true)
        end,
        description = 'Enable LSP formatting',
        opts = { buffer = bufnr },
      },
    })
  end

  if not (vim.api.nvim_buf_get_commands(0, {}) or {}).Test then
    -- Neotest
    vim.list_extend(commands, {
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
      function(args)
        vim.lsp.buf_request(
          0,
          'experimental/openCargoToml',
          { textDocument = vim.lsp.util.make_text_document_params(0) },
          function(...)
            local path = vim.tbl_get({ ... }, 2, 'uri')
            if path and #path > 0 then
              if vim.startswith(path, 'file://') then
                path = path:sub(#'file://')
              end
              if not args.bang then
                vim.cmd.vsp()
              end
              vim.cmd.e(path)
            end
          end
        )
      end,
      description = 'Open the `Cargo.toml` that is closest to the current file in the tree.',
      opts = { buffer = bufnr, bang = true },
    })
  end

  return {
    itemgroup = 'LSP',
    commands = commands,
  }
end

return M
