return {
  'echasnovski/mini.trailspace',
  event = 'VimEnter',
  config = function()
    require('mini.trailspace').setup({})
  end,
}
