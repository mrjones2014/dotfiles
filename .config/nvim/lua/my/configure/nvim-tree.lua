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
      ignore_ft_on_setup = { 'alpha' },
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
        hide_root_folder = true,
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

          -- glyphs = {
          --   default = '',
          --   symlink = '',
          --   folder = {
          --     default = '',
          --     empty = '',
          --     empty_open = '',
          --     open = '',
          --     symlink = '',
          --     symlink_open = '',
          --     arrow_open = '',
          --     arrow_closed = '',
          --   },
          --   git = {
          --     unstaged = '✗',
          --     staged = '✓',
          --     unmerged = '',
          --     renamed = '➜',
          --     untracked = '★',
          --     deleted = '',
          --     ignored = '◌',
          --   },
          -- },
        },
      },
    })
    -- require('nvim-tree').setup({
    --   renderer = { indent_markers = { enable = true } },
    --   filters = {
    --     custom = { '.git', 'node_modules', '.cache', '.DS_Store', '.netrwhist', 'dist', 'packer_compiled.lua' },
    --   },
    --   git = {
    --     ignore = true,
    --   },
    --   view = {
    --     mappings = {
    --       custom_only = true,
    --       list = {
    --         { key = { '<CR>', 'o', '<2-LeftMouse>' }, cb = tree_cb('edit') },
    --         { key = '<C-v>', cb = tree_cb('vsplit') },
    --         { key = 'R', cb = tree_cb('refresh') },
    --         { key = 'a', cb = tree_cb('create') },
    --         { key = 'd', cb = tree_cb('remove') },
    --         { key = 'r', cb = tree_cb('rename') },
    --         { key = '.', cb = tree_cb('cd') },
    --       },
    --     },
    --     side = 'right',
    --     width = 40,
    --     auto_resize = false,
    --   },
    --   update_focused_file = {
    --     enable = true,
    --     update_cwd = false,
    --   },
    --   diagnostics = {
    --     enable = true,
    --     icons = {
    --       hint = icons.Hint,
    --       info = icons.Info,
    --       warning = icons.Warning,
    --       error = icons.Error,
    --     },
    --   },
    -- })
  end,
}
