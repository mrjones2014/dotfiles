return {
  'sindrets/diffview.nvim',
  cmd = {
    'DiffviewLog',
    'DiffviewOpen',
    'DiffviewClose',
    'DiffviewRefresh',
    'DiffviewFocusFiles',
    'DiffviewFileHistory',
    'DiffviewToggleFiles',
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      file_panel = {
        win_config = {
          position = 'right',
        },
      },
    },
  },
  config = true,
}
