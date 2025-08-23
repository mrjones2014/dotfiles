return {
  cmd = { 'nil' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', 'default.nix', '.git' },
  on_init = function(client)
    -- I use two LSPs for Nix, use nixd for these features instead
    client.server_capabilities.documentSymbolProvider = false
    client.server_capabilities.renameProvider = false
  end,
}
