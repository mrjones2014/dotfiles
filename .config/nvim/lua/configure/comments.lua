return {
  'numToStr/Comment.nvim',
  config = function()
    require('Comment').setup({
      mappings = {
        basic = false,
        extended = false,
      },
    })
  end,
}
