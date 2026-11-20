---@type LazySpec
return {
  'max397574/better-escape.nvim',
  -- AstroNvim maps both `jk` and `jj`; drop `jj` because I type that to use jujutsu
  opts = { mappings = { i = { j = { j = false } } } },
}
