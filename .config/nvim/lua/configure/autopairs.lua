return {
  'windwp/nvim-autopairs',
  event = 'BufLeave', -- when leaving dashboard buffer
  config = function()
    require('nvim-autopairs').setup({})
  end,
}
