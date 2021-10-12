return {
  'kyazdani42/nvim-tree.lua',
  cmd = 'NvimTreeToggle',
  setup = function()
    -- TODO update these once they're implemented in the setup function
    vim.g.nvim_tree_gitignore = 1
    vim.g.nvim_tree_indent_markers = 1
    vim.g.nvim_tree_git_hl = 1
    vim.g.nvim_tree_add_trailing = 1
    vim.g.nvim_tree_ignore = { '.git', 'node_modules', '.cache', '.DS_Store', '.netrwhist', 'dist' }
    vim.g.nvim_tree_auto_ignore_ft = { 'TelescopePrompt', 'term', 'terminal' }
    vim.g.nvim_tree_special_files = {}

    local lspIcons = require('modules.lsp-icons')
    vim.g.nvim_tree_icons = {
      lsp = {
        hint = lspIcons.Hint,
        info = lspIcons.Information,
        warning = lspIcons.Warning,
        error = lspIcons.Error,
      },
    }
  end,
  config = function()
    local icons = require('modules.lsp-icons')
    local tree_cb = require('nvim-tree.config').nvim_tree_callback
    require('nvim-tree').setup({
      view = {
        side = 'right',
        width = 40,
        auto_resize = false,
        mappings = {
          custom_only = true,
          list = {
            { key = { '<CR>', 'o', '<2-LeftMouse>' }, cb = tree_cb('edit') },
            { key = '<C-v>', cb = tree_cb('vsplit') },
            { key = 'R', cb = tree_cb('refresh') },
            { key = 'a', cb = tree_cb('create') },
            { key = 'd', cb = tree_cb('remove') },
            { key = 'r', cb = tree_cb('rename') },
            { key = '.', cb = tree_cb('cd') },
          },
        },
      },
      update_focused_file = {
        enable = true,
        update_cwd = false,
      },
      auto_close = true,
      diagnostics = {
        enable = true,
        icons = {
          hint = icons.Hint,
          info = icons.Info,
          warning = icons.Warning,
          error = icons.Error,
        },
      },
    })
  end,
}
