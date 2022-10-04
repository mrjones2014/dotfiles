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
      history = {
        filter = {},
      },
      cmdline = {
        icons = {
          ['/'] = { icon = '  ' },
          ['?'] = { icon = '  ' },
          [':'] = { icon = '  ', firstc = ':' },
        },
      },
      routes = {
        {
          filter = { find = 'No active Snippet' },
          opts = { skip = true },
        },
        {
          filter = { kind = 'wmsg' },
          opts = { skip = true },
        },
      },
      views = {
        cmdline_popup = {
          position = {
            row = vim.o.lines - 4,
            col = 0,
          },
          size = { width = '100%' },
          border = {
            style = 'none',
            padding = { 1, 3 },
          },
          filter_options = {},
          win_options = {
            winhighlight = 'NormalFloat:CmdLine,FloatBorder:CmdLine',
          },
        },
      },
    })
  end,
}
