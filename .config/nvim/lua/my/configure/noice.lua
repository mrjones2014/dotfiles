return {
  'folke/noice.nvim',
  requires = {
    'rcarriga/nvim-notify',
    'MunifTanjim/nui.nvim',
    'hrsh7th/nvim-cmp',
  },
  event = 'VimEnter',
  config = function()
    require('noice').setup({
      history = {
        filter = {},
      },
      routes = {
        {
          filter = {
            any = {
              { find = 'No active Snippet' },
              { find = 'No signature help available' },
              { find = '^<$' },
              { kind = 'wmsg' },
            },
          },
          opts = { skip = true },
        },
      },
      views = {
        mini = {
          position = {
            row = vim.o.lines - 8,
          },
        },
        popup = {
          win_options = {
            winhighlight = {
              Normal = 'NormalFloat',
              FloatBorder = 'FloatBorder',
            },
          },
        },
        cmdline_popup = {
          position = {
            row = vim.o.lines - 4,
            col = 0,
          },
          size = { width = '100%' },
          border = {
            padding = { 0, 3 },
          },
          win_options = {
            winhighlight = {
              Normal = 'CmdLine',
              FloatBorder = 'CmdLineBorder',
            },
          },
        },
      },
    })
  end,
}
