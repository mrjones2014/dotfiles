return {
  'folke/trouble.nvim',
  module = 'trouble',
  config = function()
    require('trouble').setup({
      action_keys = {
        hover = {},
      },
    })
  end,
}
