-- customize LSP icons
local signs = require('lsp.icons')
for type, icon in pairs(signs) do
  local hl = 'LspDiagnosticsSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

-- set diagnostics to update in insert mode
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = true,
})

require('lsp.css')
require('lsp.html')
require('lsp.json')
require('lsp.typescript')
require('lsp.lua')
require('lsp.rust')
require('lsp.null-ls')
