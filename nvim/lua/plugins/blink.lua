---@type LazySpec
return {
  'saghen/blink.cmp',
  specs = {
    {
      'yus-works/csc.nvim',
      ft = 'jjdescription',
      opts = {},
      config = function(_, opts)
        require('csc').setup(opts)
        -- upstream only registers the source for `gitcommit`
        require('blink.cmp').add_filetype_source('jjdescription', 'csc')
      end,
    },
  },
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
