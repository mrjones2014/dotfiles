---@type LazySpec
return {
  { import = 'astrocommunity.utility.noice-nvim' },
  {
    'folke/noice.nvim',
    opts = {
      presets = {
        bottom_search = false,
        command_palette = false,
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
          -- pinned to the bottom, full width, nvchad-style flat bar
          position = { row = '100%', col = 0 },
          size = { width = '100%' },
          border = { padding = { 0, 3 } },
          win_options = {
            winhighlight = {
              Normal = 'NoiceCmdlinePopup',
              FloatBorder = 'NoiceCmdlinePopupBorder',
            },
          },
        },
      },
      views = {
        mini = { position = { row = '98%' } },
      },
    },
  },
}
