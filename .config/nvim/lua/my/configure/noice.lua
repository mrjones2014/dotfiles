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
      lsp = {
        signature = { enabled = true },
        hover = { enabled = true },
        documentation = {
          opts = {
            win_options = {
              concealcursor = 'n',
              conceallevel = 3,
              winhighlight = {
                Normal = 'LspFloat',
                FloatBorder = 'LspFloatBorder',
              },
            },
          },
        },
      },
      cmdline = {
        format = {
          cmdline = { icon = ' ' },
          search_down = { icon = '  ' },
          search_up = { icon = '  ' },
          filter = { icon = ' ', lang = 'fish' },
          lua = { icon = ' ' },
          help = { icon = ' ' },
        },
        opts = {
          position = {
            row = vim.o.lines - 3,
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
      },
    })
  end,
}
