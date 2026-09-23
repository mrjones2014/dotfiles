---@type LazySpec
return {
  { import = 'astrocommunity.pack.full-dadbod' },
  {
    -- the pack lists vim-dadbod bare, with no trigger, so lazy loads it at startup.
    -- vim-dadbod-ui already depends on it and is `cmd`-gated, so the only thing left
    -- to cover is dadbod's own :DB command.
    'tpope/vim-dadbod',
    lazy = true,
    cmd = 'DB',
  },
}
