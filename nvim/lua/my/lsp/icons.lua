local signs = {
  Error = ' ',
  Warning = ' ',
  Warn = ' ',
  Hint = ' ',
  Information = ' ',
  Info = ' ',
}

-- add lowercase keys and Neovim's nomenclature
for _, key in ipairs(vim.tbl_keys(signs)) do
  signs[key:lower()] = signs[key]
  signs[string.format('DiagnosticSign%s', key)] = signs[key]
end

signs[vim.diagnostic.severity.HINT] = signs.Hint
signs[vim.diagnostic.severity.INFO] = signs.Info
signs[vim.diagnostic.severity.WARN] = signs.Warn
signs[vim.diagnostic.severity.ERROR] = signs.Error

return signs
