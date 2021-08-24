return {
  'numtostr/FTerm.nvim',
  module_pattern = 'FTerm',
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
