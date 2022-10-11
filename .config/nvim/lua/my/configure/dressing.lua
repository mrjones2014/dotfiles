return {
  'stevearc/dressing.nvim',
  event = 'VimEnter',
  config = function()
    require('dressing').setup({
      select = {
        telescope = {
          layout_config = {
            width = 120,
            height = 25,
          },
        },
      },
    })
  end,
}
