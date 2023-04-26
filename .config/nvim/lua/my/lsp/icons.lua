local signs = {
  Error = ' ',
  Warning = ' ',
  Warn = ' ',
  Hint = ' ',
  Information = ' ',
  Info = ' ',
}

-- add ability to lookup by Neovim's internal nomenclature
signs.DiagnosticSignError = signs.Error
signs.DiagnosticSignWarn = signs.Warn
signs.DiagnosticSignWarning = signs.Warning
signs.DiagnosticSignHint = signs.Hint
signs.DiagnosticSignInformation = signs.Information
signs.DiagnosticSignInfo = signs.Info

return signs
