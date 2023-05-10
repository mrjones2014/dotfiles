return {
  'kevinhwang91/nvim-bqf',
  ft = 'qf', -- load on quickfix list opened,
  config = function()
    require('bqf').setup({
      func_map = {
        pscrolldown = '<C-d>',
        pscrollup = '<C-f>',
      },
    })
  end,
}
