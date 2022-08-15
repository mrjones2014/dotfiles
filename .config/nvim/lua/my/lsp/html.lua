-- Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

require('lspconfig').html.setup({
  on_attach = require('my.lsp.utils').on_attach,
  capabilities = capabilities,
  root_dir = require('lspconfig.util').root_pattern('.git'),
})
