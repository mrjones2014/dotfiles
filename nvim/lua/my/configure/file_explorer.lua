return {
  'echasnovski/mini.files',
  keys = {
    {
      '<F3>',
      function()
        require('mini.files').open(vim.loop.cwd(), true)
      end,
      desc = 'Open mini.files',
    },
  },
  opts = {
    mappings = {
      go_in_plus = '<CR>',
    },
    windows = {
      preview = true,
      width_preview = 120,
    },
  },
  config = true,
}
