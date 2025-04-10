return {
  'saghen/blink.cmp',
  version = '*',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      version = 'v2.*',
      keys = {
        {
          '<C-h>',
          function()
            require('luasnip').jump(-1)
          end,
          mode = { 'i', 's' },
          desc = 'Jump to previous snippet node',
        },
        {
          '<C-l>',
          function()
            local ls = require('luasnip')
            if ls.expand_or_jumpable() then
              ls.expand_or_jump()
            end
          end,
          mode = { 'i', 's' },
          desc = 'Expand or jump to next snippet node',
        },
        {
          '<C-j>',
          function()
            local ls = require('luasnip')
            if ls.choice_active() then
              ls.change_choice(-1)
            end
          end,
          mode = { 'i', 's' },
          desc = 'Select previous choice in snippet choice nodes',
        },
        {
          '<C-k>',
          function()
            local ls = require('luasnip')
            if ls.choice_active() then
              ls.change_choice(1)
            end
          end,
          mode = { 'i', 's' },
          desc = 'Select next choice in snippet choice nodes',
        },
        {
          '<C-s>',
          function()
            require('luasnip').unlink_current()
          end,
          mode = { 'i', 'n' },
          desc = 'Clear snippet jumps',
        },
      },
    },
    { 'folke/lazydev.nvim' },
  },
  opts = {
    enabled = function()
      return not vim.tbl_contains({ 'minifiles' }, vim.bo.filetype)
    end,
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
