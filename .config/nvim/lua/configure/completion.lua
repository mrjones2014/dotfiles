return {
  'hrsh7th/nvim-cmp',
  requires = {
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lua',
  },
  after = { 'lspkind-nvim' },
  config = function()
    local cmp = require('cmp')
    local icons = require('nvim-nonicons')
    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      mapping = {
        ['<S-tab>'] = cmp.mapping.select_prev_item(),
        ['<tab>'] = cmp.mapping.select_next_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        -- <CR> binding defined below with autopairs
      },
      sources = {
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'path' },
        { name = 'buffer' },
      },
      formatting = {
        format = require('lspkind').cmp_format({
          with_text = true,
          menu = {
            nvim_lsp = icons.get('code') .. '[LSP]',
            nvim_lua = icons.get('lua') .. '[Lua]',
            path = icons.get('folder') .. '[Path]',
            buffer = icons.get('file') .. '[Buffer]',
          },
        }),
      },
    })
    require('nvim-autopairs.completion.cmp').setup({
      map_cr = true,
      map_complete = true,
      auto_select = true,
      map_char = {
        all = '(',
        tex = '{',
      },
    })
  end,
}
