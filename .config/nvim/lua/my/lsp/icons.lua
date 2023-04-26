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

return signs
