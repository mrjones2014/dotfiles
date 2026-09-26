---@type LazySpec
return {
  'folke/which-key.nvim',
  -- I want a newer version than astronvim pins currently
  version = false,
  commit = '3aab2147e74890957785941f0c1ad87d0a44c15a',
  opts = {
    preset = 'helix',
    win = { col = 0 },
  },
}
