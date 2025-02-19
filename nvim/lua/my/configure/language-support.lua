local formatters_by_ft = require('my.lsp.filetypes').formatters_by_ft
local linters_by_ft = require('my.lsp.filetypes').linters_by_ft
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
        return { lsp_fallback = true }
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
      'hrsh7th/cmp-nvim-lsp',
      {
        'folke/neoconf.nvim',
        opts = {
          import = {
            coc = false,
            nlsp = false,
          },
        },
      },
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
    },
    event = 'BufReadPre',
    init = function()
      require('my.utils.lsp').on_attach(require('my.utils.lsp').on_attach_default)
    end,
    config = function()
      local function setup_lsp_for_filetype(filetype, server_name)
        local has_config, config = pcall(require, 'my.lsp.' .. filetype)
        config = has_config and config or {}
        config.capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

        require('lspconfig')[server_name].setup(config)
        local snippets = require('my.lsp.snippets')[filetype]
        if snippets then
          snippets()
        end
      end

      local function current_buf_matches_file_patterns(patterns)
        local bufname = vim.api.nvim_buf_get_name(0)
        for _, pattern in ipairs(patterns) do
          if string.match(bufname, string.format('.%s', pattern)) then
            return true
          end
        end

        return false
      end

      local function setup_server(filetype, file_patterns, server_name)
        -- since we're lazy loading lspconfig itself,
        -- check if we need to start LSP immediately or not
        if current_buf_matches_file_patterns(file_patterns) then
          setup_lsp_for_filetype(filetype, server_name)
        else
          -- if not, set up an autocmd to lazy load the rest
          vim.api.nvim_create_autocmd('BufReadPre', {
            callback = function()
              setup_lsp_for_filetype(filetype, server_name)
            end,
            pattern = file_patterns,
            once = true,
          })
        end
      end

      -- lazy-load the rest of the configs with
      -- an autocommand that runs only once
      -- for each lsp config
      for filetype, filetype_config in pairs(require('my.lsp.filetypes').config) do
        local file_patterns = filetype_config.patterns or { string.format('*.%s', filetype) }
        local server_name = filetype_config.lspconfig
        if file_patterns and server_name then
          if type(server_name) == 'table' then
            for _, server in ipairs(server_name) do
              setup_server(filetype, file_patterns, server)
            end
          else
            setup_server(filetype, file_patterns, server_name)
          end
        end
      end
    end,
  },
}
