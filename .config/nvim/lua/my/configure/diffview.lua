return {
  'sindrets/diffview.nvim',
  config = function()
    require('diffview').setup({
      enhanced_diff_hl = true,
      view = {
        file_panel = {
          win_config = {
            position = 'right',
          },
        },
      },
    })
  end,
}
