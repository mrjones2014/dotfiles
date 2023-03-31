return {
  'numToStr/FTerm.nvim',
  config = function()
    require('FTerm').setup({
      border = 'none',
      dimensions = {
        height = 0.9,
        width = 0.9,
      },
    })
  end,
}
