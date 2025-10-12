-- the LSP also runs shellcheck and shfmt
return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh', 'bash' },
  root_markers = { '.git' },
  ---@module 'codesettings'
  ---@type lsp.bashls
  settings = {
    bashIde = {
      globPattern = '*@(.sh|.inc|.bash|.command)',
    },
  },
}
