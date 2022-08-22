return {
  'kyazdani42/nvim-tree.lua',
  cmd = {
    'NvimTreeClipboard',
    'NvimTreeClose',
    'NvimTreeFindFile',
    'NvimFreeFindFileToggle',
    'NvimTreeFocus',
    'NvimTreeOpen',
    'NvimTreeRefresh',
    'NvimTreeResize',
    'NvimTreeToggle',
  },
  config = function()
    require('nvim-tree').setup({
      filters = {
        dotfiles = false,
      },
      disable_netrw = true,
      hijack_netrw = true,
      open_on_setup = false,
      ignore_ft_on_setup = { 'nofile' },
      hijack_cursor = true,
      hijack_unnamed_buffer_when_opening = false,
      update_cwd = true,
      update_focused_file = {
        enable = true,
        update_cwd = false,
      },
      view = {
        adaptive_size = true,
        side = 'right',
        width = 25,
        hide_root_folder = false,
        mappings = {
          custom_only = true,
          list = {
            { key = '<CR>', action = 'open_file' },
            { key = 'd', action = 'remove' },
            { key = 'a', action = 'create' },
            { key = '<C-v>', action = 'vsplit' },
          },
        },
      },
      git = {
        enable = false,
        ignore = true,
      },
      filesystem_watchers = {
        enable = true,
      },
      actions = {
        open_file = {
          resize_window = true,
        },
      },
      renderer = {
        highlight_git = false,
        highlight_opened_files = 'none',

        indent_markers = {
          enable = false,
        },

        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = false,
          },
        },
      },
    })
  end,
}
