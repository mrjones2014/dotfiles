local formatters_by_ft = require('my.lsp.filetypes').formatters_by_ft
local linters_by_ft = require('my.lsp.filetypes').linters_by_ft
local lsp_util = require('my.utils.lsp')
return {
  {
    'folke/snacks.nvim',
    lazy = false,
    opts = {
      -- open the file right away and do stuff like Treesitter/LSP lazily
      quickfile = { enabled = true },
      -- disable stuff like LSP and Treesitter from attaching if the file is massive
      bigfile = { enabled = true },
      words = { enabled = true },
    },
  },
  {
    'stevearc/conform.nvim',
    -- load for *all* languages, because it formats with LSP fallback too
    ft = vim.tbl_keys(require('my.lsp.filetypes').config),
    opts = {
      formatters_by_ft = formatters_by_ft,
      format_after_save = function()
        if not require('my.utils.lsp').is_formatting_enabled() then
          return
        end
        return { lsp_format = 'fallback' }
      end,
    },
  },
  {
    'mfussenegger/nvim-lint',
    ft = vim.tbl_keys(linters_by_ft),
    init = function()
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter' }, {
        callback = function()
          require('lint').try_lint()
        end,
      })
    end,
    config = function()
      require('lint').linters_by_ft = linters_by_ft
    end,
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    dependencies = { 'Bilal2453/luvit-meta' },
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv', 'vim%.loop' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'folke/neoconf.nvim' },
      {
        'SmiteshP/nvim-navbuddy',
        dependencies = {
          'SmiteshP/nvim-navic',
          'MunifTanjim/nui.nvim',
        },
        opts = {
          lsp = { auto_attach = true },
          window = { sections = { right = { preview = 'always' } } },
        },
        keys = {
          {
            '<F4>',
            function()
              require('nvim-navbuddy').open()
            end,
            desc = 'Jump to symbol',
          },
        },
      },
      {
        'DNLHC/glance.nvim',
        event = 'LspAttach',
        config = function()
          local glance = require('glance')
          glance.setup({ ---@diagnostic disable-line:missing-fields
            border = {
              enable = true,
            },
            theme = {
              enable = true,
              mode = 'darken',
            },
            -- make win navigation mappings consistent with my default ones
            mappings = {
              list = {
                ['<C-h>'] = glance.actions.enter_win('preview'),
              },
              preview = {
                ['<C-l>'] = glance.actions.enter_win('list'),
              },
            },
          })
        end,
      },
      {
        'chrisgrieser/nvim-rulebook',
        dev = true,
        keys = {
          {
            '<leader>ri',
            function()
              require('rulebook').ignoreRule()
            end,
            desc = 'Add comment to ignore diagnostic error/warning rules',
          },
          {
            '<leader>rl',
            function()
              require('rulebook').lookupRule()
            end,
            desc = 'Look up rule documentation for error/warning diagnostics',
          },
        },
      },
      {
        'dnlhc/glance.nvim',
        -- for whatever reason, these options don't apply
        -- using `opts = {}`, so use `config` ¯\_(ツ)_/¯
        config = function()
          require('glance').setup({
            border = { enable = false },
            theme = { mode = 'darken' },
            mappings = {
              list = {
                ['<C-h>'] = function()
                  require('glance').actions.enter_win('preview')()
                end,
              },
              prview = {
                ['<C-l>'] = function()
                  require('glance').actions.enter_win('list')()
                end,
              },
            },
          })
        end,
      },
      {
        -- otter is activated by ftplugins, see ftplugin/*
        'jmbuhr/otter.nvim',
        opts = {
          lsp = {
            root_dir = function(_, bufnr)
              return vim.fs.root(bufnr or 0, {
                '.git',
                'Cargo.lock',
                'package.json',
                'flake.nix',
              }) or vim.fn.getcwd(0)
            end,
          },
        },
      },
    },
    event = 'BufReadPre',
    init = function()
      lsp_util.on_attach(require('my.utils.lsp').on_attach_default)
      lsp_util.on_attach(function(_, bufnr)
        local function vsplit_then(callback)
          return function()
            vim.cmd.vsp()
            callback()
          end
        end

        require('which-key').add({
          {
            'gh',
            function()
              -- I have diagnostics float on CursorHold,
              -- disable that if I've manually shown the hover window
              -- see require('my.utils.lsp').on_attach_default
              vim.cmd.set('eventignore+=CursorHold')
              vim.lsp.buf.hover()
              vim.api.nvim_create_autocmd('CursorMoved', {
                command = ':set eventignore-=CursorHold',
                pattern = '<buffer>',
                once = true,
              })
            end,
            desc = 'Show LSP hover menu',
            buffer = bufnr,
          },
          { 'gs', vim.lsp.buf.signature_help, desc = 'Show signature help', buffer = bufnr },
          { 'gr', vim.lsp.buf.references, desc = 'Find references', buffer = bufnr },
          {
            'gR',
            function()
              require('glance').open('references')
            end,
            desc = 'Peek references',
            buffer = bufnr,
          },
          { 'gd', vim.lsp.buf.definition, desc = 'Go to definition', buffer = bufnr },
          {
            'gD',
            function()
              require('glance').open('definitions')
            end,
            desc = 'Peek definition',
            buffer = bufnr,
          },
          { 'gi', vim.lsp.buf.implementation, desc = 'Go to implementation', buffer = bufnr },
          {
            'gI',
            function()
              require('glance').open('implementations')
            end,
            desc = 'Peek implementation',
            buffer = bufnr,
          },
          { 'gt', vim.lsp.buf.type_definition, desc = 'Go to type definition', buffer = bufnr },
          { '<leader>gd', vsplit_then(vim.lsp.buf.definition), desc = 'Go to definition in new split', buffer = bufnr },
          {
            '<leader>gi',
            vsplit_then(vim.lsp.buf.implementation),
            desc = 'Go to implementation in new split',
            buffer = bufnr,
          },
          {
            '<leader>gt',
            vsplit_then(vim.lsp.buf.type_definition),
            desc = 'Go to type definition in new split',
            buffer = bufnr,
          },
          { '<leader>rn', vim.lsp.buf.rename, desc = 'Rename symbol', buffer = bufnr },
          { 'F', vim.lsp.buf.code_action, desc = 'Show code actions', buffer = bufnr },
        })
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
          require('conform').format({ async = true, lsp_format = 'fallback' })
        end, { desc = 'Format file' })
      end)
    end,
    config = function()
      require('neoconf').setup({}) -- ensure neoconf loads first
      local function setup_lsp_for_filetype(filetype, server_name)
        local has_config, config = pcall(require, 'my.lsp.' .. filetype)
        config = has_config and config or {}
        config.capabilities = require('blink.cmp').get_lsp_capabilities()

        require('lspconfig')[server_name].setup(config)
        local snippets = require('my.lsp.snippets')[filetype]
        if snippets then
          snippets()
        end
      end

      local function setup_server(filetype, server_name)
        setup_lsp_for_filetype(filetype, server_name)
      end

      -- set up ast-grep LSP for all languages
      if vim.fn.executable('ast-grep') ~= 0 then
        require('lspconfig').ast_grep.setup({})
      end

      for filetype, filetype_config in pairs(require('my.lsp.filetypes').config) do
        local server_name = filetype_config.lspconfig
        if server_name then
          if type(server_name) == 'table' then
            for _, server in ipairs(server_name) do
              setup_server(filetype, server)
            end
          else
            setup_server(filetype, server_name)
          end
        end
      end
    end,
  },
}
