-- customize LSP icons
local icons = require('my.lsp.icons')
for type, icon in pairs(icons) do
  local highlight = 'DiagnosticSign' .. type
  local legacy_highlight = 'LspDiagnosticsSign' .. type
  vim.fn.sign_define(highlight, { text = icon, texthl = highlight, numhl = highlight })
  vim.fn.sign_define(legacy_highlight, { text = icon, texthl = legacy_highlight, numhl = legacy_highlight })
end

local icon_map = {
  [vim.diagnostic.severity.ERROR] = icons.Error,
  [vim.diagnostic.severity.WARN] = icons.Warn,
  [vim.diagnostic.severity.INFO] = icons.Info,
  [vim.diagnostic.severity.HINT] = icons.Hint,
}

local function diagnostic_format(diagnostic)
  if diagnostic.source == 'eslint' or diagnostic.source == 'eslint_d' then
    return string.format('%s %s (%s)', icon_map[diagnostic.severity], diagnostic.message, diagnostic.code)
  end

  return string.format('%s %s', icon_map[diagnostic.severity], diagnostic.message)
end

vim.diagnostic.config({
  virtual_text = {
    format = diagnostic_format,
    prefix = '',
  },
  float = {
    format = diagnostic_format,
  },
  signs = { priority = 1000000 },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- enable virtual text diagnostics for Neotest only
vim.diagnostic.config({ virtual_text = true }, vim.api.nvim_create_namespace('neotest'))

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
