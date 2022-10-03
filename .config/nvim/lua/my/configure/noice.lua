return {
  'folke/noice.nvim',
  requires = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
    'hrsh7th/nvim-cmp',
  },
  event = 'VimEnter',
  config = function()
    require('noice').setup({
      routes = {
        {
          filter = { find = 'No active Snippet' },
          opts = { skip = true },
        },
      },
      views = {
        cmdline_popup = {
          border = {
            padding = { 2, 3 },
          },
          filter_options = {},
          win_options = {
            winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
          },
        },
      },
    })
  end,
}
