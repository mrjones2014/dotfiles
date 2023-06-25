-- make mini.splitjoin work properly for Nix lists which don't have comma separators, Nix uses space separators instead.
if _G.MiniSplitjoin == nil then
  -- if not loaded already, load it now
  require('mini.splitjoin')
end
-- Pad square brackets with single space after join
local pad_brackets = MiniSplitjoin.gen_hook.pad_brackets({ brackets = { '%b[]' } })

vim.b.minisplitjoin_config = {
  detect = { separator = '[^[]%f[ ] +' },
  join = { hooks_post = { pad_brackets } },
}
