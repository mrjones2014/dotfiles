-- Plugins pulled in by AstroNvim core or the language packs that I don't use.
-- All of these are lazy, so they cost nothing at runtime, but they're dead weight
-- in the lockfile and on disk.

---@type LazySpec
return {
  -- orphaned: AstroNvim registers it with no load trigger, and its only consumer
  -- (neo-tree) is disabled by the mini-files pack
  { 's1n7ax/nvim-window-picker', enabled = false },

  -- AstroNvim features I don't use
  { 'akinsho/toggleterm.nvim', enabled = false },
  { 'stevearc/resession.nvim', enabled = false },

  -- pack.typescript extras: I use ts_ls, not vtsls
  { 'yioneko/nvim-vtsls', enabled = false },
  { 'dmmulroy/tsc.nvim', enabled = false },
  { 'vuki656/package-info.nvim', enabled = false },

  -- other language-pack extras
  { 'olexsmir/gopher.nvim', enabled = false },
  { 'Civitasv/cmake-tools.nvim', enabled = false },
}
