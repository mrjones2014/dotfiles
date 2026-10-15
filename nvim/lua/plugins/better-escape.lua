return {
  'max397574/better-escape.nvim',
  event = 'VeryLazy',
  opts = {
    timeout = 300,
    default_mappings = false,
    mappings = {
      -- do not map `jj` because I type that to use jujutsu
      i = { j = { k = '<Esc>', j = false } },
    },
  },
}
