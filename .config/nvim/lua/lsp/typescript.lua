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

local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = ""
  }
  vim.lsp.buf.execute_command(params)
end

require('lspconfig').tsserver.setup({
  on_attach = on_attach,
  commands = {
    OrganizeImports = {
      organize_imports,
      description = "Organize Imports"
    }
  }
})
