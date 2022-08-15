require('lspconfig').jsonls.setup({
  capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
  on_attach = require('my.lsp.utils').on_attach,
  root_dir = require('lspconfig.util').root_pattern('.git'),
})
