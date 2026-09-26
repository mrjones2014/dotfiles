---@type vim.lsp.Config
return {
  root_markers = { 'flake.nix', 'default.nix', '.git' },
  on_init = function(client)
    -- I run two LSPs for Nix; nixd handles these features
    client.server_capabilities.documentSymbolProvider = false
    client.server_capabilities.renameProvider = false
  end,
}
