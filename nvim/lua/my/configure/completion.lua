return {
  'saghen/blink.cmp',
  version = '*',
  dependencies = {
    { 'L3MON4D3/LuaSnip', version = 'v2.*' },
    { 'folke/lazydev.nvim' },
  },
  opts = {
    snippets = { preset = 'luasnip' },
    signature = { enabled = true },
    keymap = {
      preset = 'enter',
      ['<Tab>'] = { 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'fallback' },
      ['<Left>'] = {},
      ['<Right>'] = {},
    },
    completion = {
      menu = {
        draw = {
          columns = {
            { 'label', 'label_description', gap = 1 },
            { 'kind_icon', 'kind' },
          },
        },
      },
      documentation = { auto_show = true, auto_show_delay_ms = 0 },
      ghost_text = { enabled = true },
    },
    cmdline = {
      keymap = {
        ['<Left>'] = {},
        ['<Right>'] = { 'accept', 'fallback' },
      },
      completion = {
        menu = { auto_show = true },
      },
    },
    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          -- boost lazydev suggestions to top
          score_offset = 100,
        },
      },
    },
  },
}
