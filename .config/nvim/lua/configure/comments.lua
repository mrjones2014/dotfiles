return {
  'numToStr/Comment.nvim',
  config = function()
    require('Comment').setup({
      mappings = {
        basic = false,
        extra = false,
      },
    })
  end,
}
