require('lspconfig').jsonls.setup({
  on_attach = require('modules.lsp-utils').on_attach,
  root_dir = require('lspconfig/util').root_pattern('.git'),
})
