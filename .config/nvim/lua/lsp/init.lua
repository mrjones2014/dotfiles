-- customize LSP icons
local signs = require('lsp.icons')
for type, icon in pairs(signs) do
  local highlight = 'DiagnosticSign' .. type
  vim.fn.sign_define(highlight, { text = icon, texthl = highlight, numhl = '' })
end

-- set diagnostics to update in insert mode
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = true,
  severity_sort = true,
})

require('lsp.ui-customization')

require('lsp.css')
require('lsp.html')
require('lsp.json')
require('lsp.typescript')
require('lsp.lua')
require('lsp.rust')
require('lsp.csharp')
require('lsp.null-ls')
