require('lspconfig').tsserver.setup({
  on_attach = require('modules.lsp-utils').on_attach,
})
