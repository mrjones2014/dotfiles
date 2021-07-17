-- Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require('lspconfig').html.setup({
  on_attach = require("lsp-servers/utils").on_attach,
  capabilities = capabilities,
})
