-- customize LSP icons
local signs = require('lsp.icons')
for type, icon in pairs(signs) do
  local highlight = 'DiagnosticSign' .. type
  local legacy_highlight = 'LspDiagnosticsSign' .. type
  vim.fn.sign_define(highlight, { text = icon, texthl = highlight, numhl = highlight })
  vim.fn.sign_define(legacy_highlight, { text = icon, texthl = legacy_highlight, numhl = legacy_highlight })
end

local function diagnostic_format(diagnostic)
  if diagnostic.source == 'eslint' or diagnostic.source == 'eslint_d' then
    return string.format('%s (%s)', diagnostic.message, diagnostic.code)
  end

  return diagnostic.message
end

vim.diagnostic.config({
  virtual_text = {
    format = diagnostic_format,
  },
  float = {
    format = diagnostic_format,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
