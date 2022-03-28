return {
  'hrsh7th/nvim-cmp',
  requires = {
    'onsails/lspkind-nvim',
    'saadparwaiz1/cmp_luasnip',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-cmdline',
  },
  branch = 'dev',
  after = { 'nvim-autopairs', 'LuaSnip' },
  config = function()
    local luasnip = require('luasnip')
    luasnip.config.setup({
      history = true,
      updateevents = 'TextChanged,TextChangedI',
    })
    local cmp = require('cmp')
    local shared_config = {
      window = {
        completion = {
          border = 'rounded',
        },
        documentation = {
          border = 'rounded',
        },
      },
      preselect = cmp.PreselectMode.None,
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = {
        completeopt = 'menu,menuone,noinsert',
      },
      mapping = require('keymap').cmp_mappings(),
      formatting = {
        format = require('lspkind').cmp_format({ with_text = true }),
      },
      experimental = {
        ghost_text = true,
      },
    }

    -- diagnostics thinks `setup` isn't a function
    -- because of how `setup.cmdline` is called as
    -- a function below
    ---@diagnostic disable-next-line: redundant-parameter
    cmp.setup(vim.tbl_deep_extend('force', shared_config, {
      sources = {
        { name = 'luasnip' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'nvim_lua' },
        { name = 'path' },
        { name = 'buffer' },
      },
    }))
    cmp.setup.cmdline(':', vim.tbl_deep_extend('force', shared_config, { sources = { { name = 'cmdline' } } }))
    cmp.setup.cmdline('/', vim.tbl_deep_extend('force', shared_config, { sources = { { name = 'buffer' } } }))
  end,
}
