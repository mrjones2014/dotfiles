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
      hooks = {
        view_opened = function()
          local offset = string.rep(' ', 36)
          local keymaps_str =
            '[x = prev conflict, ]x = next conflict, <leader>co = choose ours, <leader>ct = choose theirs, <leader>cb = choose base, <leader>ca = choose all, dx = choose none'
          vim.opt.tabline = offset .. keymaps_str
          vim.opt.showtabline = 2
        end,
        view_closed = function()
          vim.opt.tabline = nil
          vim.opt.showtabline = 0
        end,
      },
    })
  end,
}
