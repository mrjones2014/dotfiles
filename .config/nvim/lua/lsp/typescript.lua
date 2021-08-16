local utils = require('lsp/utils')

require('lspconfig').tsserver.setup({
  on_attach = utils.on_attach,
})
