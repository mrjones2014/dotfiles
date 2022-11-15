return {
  'nvim-zh/colorful-winsep.nvim',
  event = 'WinNew',
  config = function()
    require('colorful-winsep').setup()
  end,
}
