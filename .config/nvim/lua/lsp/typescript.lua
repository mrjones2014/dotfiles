local utils = require('lsp/utils')
local rootUtils = require('lspconfig/util')

require('lspconfig').tsserver.setup({
  on_attach = utils.on_attach,
  root_dir = rootUtils.root_pattern('.git'),
})
