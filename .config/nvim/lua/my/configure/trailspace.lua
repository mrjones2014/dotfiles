return {
  'echasnovski/mini.trailspace',
  event = 'BufWritePre',
  config = function()
    require('mini.trailspace').setup({})
  end,
}
