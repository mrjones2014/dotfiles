---@type LazySpec
return {
  { import = 'astrocommunity.utility.noice-nvim' },
  {
    'folke/noice.nvim',
    opts = {
      presets = {
        -- the pack turns this on; it routes search_up/search_down to the thin
        -- `cmdline` view instead of the full-height `cmdline_popup` bar
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
