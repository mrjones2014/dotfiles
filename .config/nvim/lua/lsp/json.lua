local utils = require('lspconfig/util')

require('lspconfig').jsonls.setup({
  on_attach = require('lsp/utils').on_attach,
  root_dir = utils.root_pattern('.git'),
})
