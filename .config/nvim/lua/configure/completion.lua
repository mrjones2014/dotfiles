--[[ return {
  'hrsh7th/nvim-cmp',
  requires = {
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lua',
  },
  after = { 'lspkind-nvim' },
  config = function()
    local cmp = require('cmp')
    local icons = require('nvim-nonicons')
    local lspkind = require('lspkind')
    cmp.setup({
      mapping = {
        ['<S-tab>'] = cmp.mapping.select_prev_item(),
        ['<tab>'] = cmp.mapping.select_next_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<CR>'] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        }),
      },
      sources = {
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'path' },
        { name = 'buffer' },
      },
      formatting = {
        format = function(entry, vim_item)
          vim_item.kind = lspkind.presets.default[vim_item.kind] .. ' ' .. vim_item.kind
          vim_item.menu = ({
            nvim_lsp = '[LSP]',
            nvim_lua = '[Lua]',
            path = '[Path]',
            buffer = '[Buffer]',
          })[entry.source.name]
        end,
      },
    })
  end,
} ]]

return {
  'hrsh7th/nvim-compe',
  config = function()
    local icons = require('nvim-nonicons')

    require('compe').setup({
      enabled = true,
      autocomplete = true,
      debug = false,
      min_length = 1,
      preselect = 'enable',
      throttle_time = 80,
      source_timeout = 200,
      incomplete_delay = 400,
      max_abbr_width = 100,
      max_kind_width = 100,
      max_menu_width = 100,
      documentation = true,

      source = {
        -- vsnip = {kind = '   (Snippet)', priority = 6}, -- enable when I get to adding vsnip
        nvim_lsp = { kind = ' ' .. icons.get('code') .. '  (LSP)', priority = 5 },
        nvim_lua = { kind = ' ' .. icons.get('lua') .. '  (nvim Lua)', priority = 4 },
        path = { kind = ' ' .. icons.get('ellipsis') .. '  (Path)', priority = 3 },
        buffer = { kind = ' ' .. icons.get('file') .. '  (Buffer)', priority = 2 },
        spell = { kind = ' ' .. icons.get('pencil') .. '  (Spell)', priority = 1 },
      },
    })
  end,
}
