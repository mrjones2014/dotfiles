return {
  'windwp/nvim-autopairs',
  event = 'BufEnter',
  config = function()
    require('nvim-autopairs').setup({})
  end,
}
