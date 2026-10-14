return {
  'max397574/better-escape.nvim',
  event = 'VeryLazy',
  opts = {
    timeout = 300,
    default_mappings = false,
    mappings = {
      i = {
        j = {
          k = '<Esc>',
          -- do not map `jj` because I type that to use jujutsu
          j = false,
        },
        -- map `kj` as well as `jk`
        k = { j = '<Esc>' },
      },
    },
  },
}
