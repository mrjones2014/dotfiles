--- Community modules without any config overrides lumped together here

---@type LazySpec
return {
  'AstroNvim/astrocommunity',

  -- language packs
  { import = 'astrocommunity.pack.bash' },
  { import = 'astrocommunity.pack.cpp' },
  { import = 'astrocommunity.pack.fish' },
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
  { import = 'astrocommunity.editing-support.mini-splitjoin' },

  -- UI/UX
  { import = 'astrocommunity.diagnostics.trouble-nvim' },
  { import = 'astrocommunity.git.octo-nvim' },
  { import = 'astrocommunity.motion.flash-nvim' },
  { import = 'astrocommunity.neovim-lua-development.helpview-nvim' },
  { import = 'astrocommunity.search.grug-far-nvim' },
}
