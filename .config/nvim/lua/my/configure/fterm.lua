return {
  'numToStr/FTerm.nvim',
  config = function()
    require('FTerm').setup({
      border = 'single',
      dimensions = {
        height = 0.9,
        width = 0.9,
      },
    })
  end,
}
