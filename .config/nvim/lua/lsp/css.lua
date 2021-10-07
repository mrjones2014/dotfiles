-- Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require('lspconfig').cssls.setup({
  on_attach = require('modules.lsp-utils').on_attach,
  capabilities = capabilities,
  root_dir = require('lspconfig/util').root_pattern('.git'),
})
