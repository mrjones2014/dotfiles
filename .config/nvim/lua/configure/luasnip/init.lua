return {
  'L3MON4D3/LuaSnip',
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
  end,
}
