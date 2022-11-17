return {
  'echasnovski/mini.trailspace',
  event = 'BufRead',
  config = function()
    require('mini.trailspace').setup({})
  end,
}
