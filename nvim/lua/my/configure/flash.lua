return {
  'folke/flash.nvim',
  keys = {
    {
      's',
      function()
        require('flash').jump()
      end,
      mode = { 'n', 'x', 'o' },
      desc = 'Jump forwards',
    },
    {
      'S',
      function()
        require('flash').jump({ search = { forward = false } })
      end,
      mode = { 'n', 'x', 'o' },
      desc = 'Jump backwards',
    },
  },
  opts = {
    jump = { nohlsearch = true },
  },
}
