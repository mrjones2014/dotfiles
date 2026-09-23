-- AstroCommunity modules I take as-is.
--
-- Anything I *override* is colocated with its override in `lua/plugins/<name>.lua`
-- instead of being listed here. Note that `{ import = ..., specs = { ... } }` does
-- not work: lazy's importer only reads `name`/`cond`/`enabled`/`import` off an import
-- spec and silently drops everything else. Sibling entries in the same file do work.

---@type LazySpec
return {
  'AstroNvim/astrocommunity',

  -- language packs
  { import = 'astrocommunity.pack.bash' },
  { import = 'astrocommunity.pack.cpp' },
  { import = 'astrocommunity.pack.go' },
  { import = 'astrocommunity.pack.jj' },
  { import = 'astrocommunity.pack.json' },
  { import = 'astrocommunity.pack.just' },
  { import = 'astrocommunity.pack.lua' },
  { import = 'astrocommunity.pack.markdown' },
  { import = 'astrocommunity.pack.nix' },
  { import = 'astrocommunity.pack.toml' },
  { import = 'astrocommunity.pack.typescript' },
  { import = 'astrocommunity.pack.yaml' },

  -- I install deps through nix, don't use mason.nvim,
  -- default formatting setup depends on mason.nvim,
  -- use conform.nvim instead
  { import = 'astrocommunity.editing-support.conform-nvim' },
  { import = 'astrocommunity.lsp.nvim-lint' },

  -- tooling I already used
  { import = 'astrocommunity.git.octo-nvim' },
  { import = 'astrocommunity.search.grug-far-nvim' },
  { import = 'astrocommunity.diagnostics.trouble-nvim' },
  { import = 'astrocommunity.motion.flash-nvim' },
}
