return {
  'folke/noice.nvim',
  dependencies = {
    'rcarriga/nvim-notify',
    'MunifTanjim/nui.nvim',
  },
  event = 'VeryLazy',
  opts = {
    lsp = {
      signature = { enabled = true },
      hover = { enabled = true },
      documentation = {
        opts = {
          win_options = {
            concealcursor = 'n',
            conceallevel = 3,
            winhighlight = { Normal = 'LspFloat' },
          },
        },
      },
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true,
      },
    },
    cmdline = {
      format = {
        cmdline = { icon = ' ' },
        search_down = { icon = '  ' },
        search_up = { icon = '  ' },
        filter = { icon = ' ', lang = 'fish' },
        lua = { icon = ' ' },
        help = { icon = ' 󰋖' },
      },
      opts = {
        position = {
          row = '98%',
          col = 0,
        },
        size = { width = '100%' },
        border = {
          padding = { 0, 3 },
        },
        win_options = {
          winhighlight = {
            Normal = 'SnacksPickerInput',
            FloatBorder = 'SnacksPickerInputBorder',
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
          row = '98%',
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
  },
}
