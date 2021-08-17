local utils = require('modules.lsp-utils')

require('lspconfig').tsserver.setup({
  on_attach = utils.on_attach,
})
