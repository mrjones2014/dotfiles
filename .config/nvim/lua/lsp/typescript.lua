require('lspconfig').tsserver.setup({
  capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
  on_attach = require('lsp.utils').on_attach,
  root_dir = require('lsp.utils').typescript_root_dir(),
})
