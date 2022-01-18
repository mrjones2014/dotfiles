require('lspconfig').rust_analyzer.setup({
  on_attach = require('lsp.utils').on_attach,
  capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
  -- set root_dir explicitly so that individual project root is detected in monorepos
  root_dir = require('lspconfig.util').root_pattern('Cargo.toml', 'rust-project.json'),
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = 'clippy',
      },
    },
  },
})
