return {
  'terrortylor/nvim-comment',
  config = function()
    require('nvim_comment').setup({
      comment_empty = false,
      create_mappings = false,
    })
  end,
}
