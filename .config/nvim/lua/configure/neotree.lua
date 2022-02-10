return {
  'nvim-neo-tree/neo-tree.nvim',
  requires = { 'MunifTanjim/nui.nvim' },
  config = function()
    require('neo-tree').setup({
      popup_border_style = 'rounded',
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 1, -- extra padding on left hand side
          with_markers = true,
          indent_marker = '│',
          last_indent_marker = '└',
          highlight = 'NeoTreeIndentMarker',
        },
        icon = {
          folder_closed = '',
          folder_open = '',
          default = '',
        },
      },
      filesystem = {
        follow_current_file = true,
        use_libuv_file_watcher = true,
        filters = {
          show_hidden = true,
          respect_gitignore = true,
        },
        window = {
          position = 'right',
        },
      },
    })
  end,
}
