local utils = require('lsp/utils')
local tsUtils = require('nvim-lsp-ts-utils')
local on_attach = function(client, buffnr)
  utils.on_attach()
  tsUtils.setup {
    enable_import_on_completion = true,
    eslint_enable_diagnostics = true,
  }
  tsUtils.setup_client(client)
end

require('lspconfig').tsserver.setup({
  on_attach = on_attach,
})
