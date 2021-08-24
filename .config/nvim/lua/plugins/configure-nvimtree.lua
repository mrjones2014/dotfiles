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
