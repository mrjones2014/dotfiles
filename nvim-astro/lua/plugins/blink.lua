---@type LazySpec
return {
  'saghen/blink.cmp',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      ['<CR>'] = { 'select_and_accept', 'fallback' },
    },
    completion = {
      list = { selection = { preselect = true } },
      menu = { border = 'none' },
      documentation = { window = { border = 'none' } },
    },
    signature = { window = { border = 'none' } },
    cmdline = {
      completion = { menu = { auto_show = true } },
    },
  },
}
