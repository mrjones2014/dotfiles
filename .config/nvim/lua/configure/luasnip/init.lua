return {
  'L3MON4D3/LuaSnip',
  requires = { 'danymat/neogen' },
  config = function()
    require('luasnip').config.setup({
      ext_opts = {
        [require('luasnip.util.types').choiceNode] = {
          active = {
            virt_text = { { '●', 'LspDiagnosticsSignInformation' } },
          },
        },
      },
    })

    require('configure.luasnip.snippets')
    require('neogen').setup({ snippet_engine = 'luasnip' })
  end,
}
