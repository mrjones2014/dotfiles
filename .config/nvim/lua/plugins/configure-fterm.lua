return {
  'numtostr/FTerm.nvim',
  config = function()
    require('FTerm').setup({
      dimensions = {
        height = 0.75,
        width = 0.5,
        x = 0.05,
      },
      border = 'rounded',
    })
  end,
}
