return {
  'hrsh7th/nvim-cmp',
  dependencies = {

    { 'saadparwaiz1/cmp_luasnip' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-cmdline', event = 'CmdlineEnter' },
    {
      'hrsh7th/cmp-nvim-lsp',
      ft = require('my.lsp.filetypes').filetypes,
      dependencies = { 'onsails/lspkind-nvim' },
    },
    { 'mtoohey31/cmp-fish', ft = 'fish', cond = not not string.find(vim.env.SHELL, 'fish') },
    {
      'L3MON4D3/LuaSnip',
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
      config = function()
        require('luasnip').config.setup({
          history = true,
          updateevents = 'TextChanged,TextChangedI',
          ext_opts = {
            [require('luasnip.util.types').choiceNode] = {
              active = {
                virt_text = { { '', 'DiagnosticSignInfo' } },
              },
            },
          },
        })
      end,
    },
  },
  event = { 'InsertEnter', 'CmdlineEnter' },
  config = function()
    local cmp = require('cmp')
    local window_config = cmp.config.window.bordered({
      border = 'none',
      winhighlight = 'Normal:LspFloat,FloatBorder:LspFloatBorder,CursorLine:Visual,Search:None',
    })
    local shared_config = {
      window = {
        completion = window_config,
        documentation = window_config,
      },
      preselect = cmp.PreselectMode.None,
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      completion = {
        completeopt = 'menu,menuone,noinsert',
      },
      mapping = require('my.legendary.keymap').cmp_mappings(),
      formatting = {
        format = function(...)
          return require('lspkind').cmp_format({ with_text = true })(...)
        end,
      },
    }

    cmp.setup(vim.tbl_deep_extend('force', shared_config, { ---@diagnostic disable-line:redundant-parameter
      sources = {
        { name = 'luasnip', priority = 100 },
        { name = 'nvim_lsp', priority = 90 },
        { name = 'fish' },
        { name = 'path', priority = 5 },
        { name = 'buffer', priority = 1 },
      },
    }))

    cmp.setup.cmdline(':', vim.tbl_deep_extend('force', shared_config, { sources = { { name = 'cmdline' } } }))
    cmp.setup.cmdline({ '/', '?' }, vim.tbl_deep_extend('force', shared_config, { sources = { { name = 'buffer' } } }))
  end,
}
