return {
  'kyazdani42/nvim-tree.lua',
  cmd = 'NvimTreeToggle',
  setup = function()
    local lspIcons = require('modules.lsp-icons')

    vim.g.nvim_tree_side = 'right'
    vim.g.nvim_tree_width = 40
    vim.g.nvim_tree_auto_open = 0
    vim.g.nvim_tree_auto_close = 1
    vim.g.nvim_tree_follow = 1
    vim.g.nvim_tree_indent_markers = 1
    vim.g.nvim_tree_git_hl = 1
    vim.g.nvim_tree_gitignore = 1
    vim.g.nvim_tree_add_trailing = 1
    vim.g.nvim_tree_ignore = { '.git', 'node_modules', '.cache', '.DS_Store', '.netrwhist', 'dist' }
    vim.g.nvim_tree_special_files = {}
    vim.g.nvim_tree_lsp_diagnostics = 1
    vim.g.nvim_tree_auto_ignore_ft = { 'TelescopePrompt', 'term', 'terminal' }
    vim.g.nvim_tree_disable_default_keybindings = 1
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
    local tree_cb = require('nvim-tree.config').nvim_tree_callback

    vim.g.nvim_tree_bindings = {
      { key = { '<CR>', 'o', '<2-LeftMouse>' }, cb = tree_cb('edit') },
      { key = '<C-v>', cb = tree_cb('vsplit') },
      { key = 'R', cb = tree_cb('refresh') },
      { key = 'a', cb = tree_cb('create') },
      { key = 'd', cb = tree_cb('remove') },
      { key = 'r', cb = tree_cb('rename') },
      { key = '.', cb = tree_cb('cd') },
    }
  end,
}
