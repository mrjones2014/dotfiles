return {
  'folke/flash.nvim',
  config = function()
    require('flash').setup({
      jump = { nohlsearch = true },
    })
  end,
}
