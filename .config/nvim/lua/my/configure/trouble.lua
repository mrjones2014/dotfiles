return {
  'folke/trouble.nvim',
  after = 'telescope.nvim',
  module = 'trouble',
  config = function()
    require('trouble').setup({
      action_keys = {
        hover = {},
      },
    })
  end,
}
