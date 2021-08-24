return {
  'folke/trouble.nvim',
  config = function()
    require('trouble').setup({
      action_keys = {
        hover = {},
      },
    })
  end,
}
