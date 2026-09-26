-- I use nix to install stuff, disable all mason-related plugins

---@type LazySpec
return {
  { 'mason-org/mason.nvim', enabled = false },
  { 'mason-org/mason-lspconfig.nvim', enabled = false },
  { 'WhoIsSethDaniel/mason-tool-installer.nvim', enabled = false },
  { 'jay-babu/mason-null-ls.nvim', enabled = false },
  { 'jay-babu/mason-nvim-dap.nvim', enabled = false },
  { 'nvimtools/none-ls.nvim', enabled = false },
}
