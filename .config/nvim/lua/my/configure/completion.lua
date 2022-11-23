return {
  { 'onsails/lspkind-nvim', after = 'nvim-cmp' },
  { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
  { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
  { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
  { 'hrsh7th/cmp-cmdline', event = 'CmdlineEnter' },
  { 'hrsh7th/cmp-nvim-lsp', ft = require('my.lsp.filetypes').filetypes },
  { 'mtoohey31/cmp-fish', ft = 'fish' },
  {
    'L3MON4D3/LuaSnip',
    after = 'nvim-cmp',
    config = function()
      require('luasnip').config.setup({
        history = true,
        updateevents = 'TextChanged,TextChangedI',
        ext_opts = {
          [require('luasnip.util.types').choiceNode] = {
            active = {
              virt_text = { { '●', 'LspDiagnosticsSignInformation' } },
            },
          },
        },
      })
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter' },
    keys = { { 'v', ':' }, { 'n', ':' } },
    module = 'cmp',
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
        experimental = {
          ghost_text = true,
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
      cmp.setup.cmdline(
        { '/', '?' },
        vim.tbl_deep_extend('force', shared_config, { sources = { { name = 'buffer' } } })
      )
    end,
  },
}
