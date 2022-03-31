require('lspconfig').rust_analyzer.setup({
  on_attach = require('lsp.utils').on_attach,
  capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = 'clippy',
      },
      files = {
        excludeDirs = { './js/', './node_modules/', './target/' },
      },
    },
  },
})
