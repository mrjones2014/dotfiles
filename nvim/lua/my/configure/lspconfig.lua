return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    {
      'creativenull/efmls-configs-nvim',
      dev = true,
      -- neoconf must be loaded before any LSP
      dependencies = { 'folke/neoconf.nvim' },
      enabled = true,
      event = 'BufReadPre',
      config = function()
        local efmls = require('efmls-configs')
        efmls.init({
          init_options = {
            documentFormatting = true,
          },
        })
        efmls.setup(require('my.lsp.filetypes').efmls_config())
      end,
    },
    { 'folke/neodev.nvim', event = 'BufReadPre' },
    {
      'folke/neoconf.nvim',
      event = 'BufReadPre',
      opts = {
        import = {
          coc = false,
          nlsp = false,
        },
      },
    },
    {
      'DNLHC/glance.nvim',
      event = 'LspAttach',
      config = function()
        local glance = require('glance')
        glance.setup({
          border = {
            enable = true,
          },
          theme = {
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
      'simrat39/symbols-outline.nvim',
      config = true,
      keys = {
        {
          '<F4>',
          function()
            require('symbols-outline').toggle_outline()
          end,
          desc = 'Toggle symbols outline',
        },
      },
    },
  },
  event = 'BufReadPre',
  init = function()
    LSP.on_attach(require('my.lsp.utils').on_attach)
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
      local bufname = vim.fn.expand('%')
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
}
