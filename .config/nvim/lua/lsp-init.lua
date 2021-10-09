-- customize LSP icons
local signs = require('modules.lsp-icons')
for type, icon in pairs(signs) do
  local hl = 'LspDiagnosticsSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

require('lsp.css')
require('lsp.html')
require('lsp.json')
require('lsp.typescript')
require('lsp.lua')
require('lsp.rust')
require('lsp.null-ls')
