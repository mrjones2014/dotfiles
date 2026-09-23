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

  -- cmp-dap ships `after/plugin/cmp_dap.lua` containing a bare
  -- `require('cmp').register_source(...)`. nvim-cmp isn't installed (AstroNvim v6
  -- uses blink.cmp), so the moment anything packadds it — e.g. rustaceanvim asking
  -- nvim-dap for debuggables — it throws `module 'cmp' not found`. AstroNvim does
  -- route it through blink.compat, but that can't stop the after/plugin file from
  -- running, so the plugin is simply unusable without nvim-cmp. astrocommunity's own
  -- non-cmp completion packs (mini-completion, coq_nvim, coc-nvim) disable it the
  -- same way.
  --
  -- Consequence: blink won't complete inside dap-repl / dapui_watches / dapui_hover
  -- buffers, since AstroNvim gates that on `is_available "cmp-dap"` (blink.lua:82).
  { 'rcarriga/cmp-dap', enabled = false },

  -- only consumer was cmp-dap's blink bridge, which is now disabled too
  { 'saghen/blink.compat', enabled = false },
}
