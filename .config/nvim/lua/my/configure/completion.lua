return {
  'hrsh7th/nvim-cmp',
  requires = {
    'onsails/lspkind-nvim',
    'saadparwaiz1/cmp_luasnip',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    { 'hrsh7th/cmp-nvim-lua', ft = 'lua' },
    { 'mtoohey31/cmp-fish', ft = 'fish' },
  },
  after = { 'LuaSnip' },
  config = function()
    local luasnip = require('luasnip')
    luasnip.config.setup({
      history = true,
      updateevents = 'TextChanged,TextChangedI',
    })
    local cmp = require('cmp')
    local shared_config = {
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
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
      mapping = require('my.legendary.keymap').cmp_mappings(),
      formatting = {
        format = require('lspkind').cmp_format({ with_text = true }),
      },
      experimental = {
        ghost_text = true,
      },
    }

    cmp.setup(vim.tbl_deep_extend('force', shared_config, {
      sources = {
        { name = 'luasnip', priority = 100 },
        { name = 'nvim_lsp', priority = 90 },
        { name = 'nvim_lsp_signature_help' },
        { name = 'nvim_lua', priority = 90 },
        { name = 'fish' },
        { name = 'path', priority = 5 },
        { name = 'buffer', priority = 1 },
      },
    }))

    cmp.setup.cmdline(':', vim.tbl_deep_extend('force', shared_config, { sources = { { name = 'cmdline' } } }))
    cmp.setup.cmdline('/', vim.tbl_deep_extend('force', shared_config, { sources = { { name = 'buffer' } } }))
  end,
}
