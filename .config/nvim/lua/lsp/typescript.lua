local utils = require('lsp/utils')
local rootUtils = require('lspconfig/util')

local function organize_imports_and_format()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = ""
  }
  vim.lsp.buf_request_sync(vim.api.nvim_get_current_buf(), "workspace/executeCommand", params, 1500)
  vim.cmd('Prettier')
end

require('lspconfig').tsserver.setup({
  on_attach = utils.on_attach,
  root_dir = rootUtils.root_pattern('.git'),
  commands = {
    OrganizeAndFormat = {
      organize_imports_and_format,
      description = "Organize Imports"
    }
  }
})
