local g = vim.g
g.nvim_tree_side = "right"
g.nvim_tree_width = 40
g.nvim_tree_auto_open = 0
g.nvim_tree_auto_close = 1
g.nvim_tree_follow = 1
g.nvim_tree_indent_markets = 1
g.nvim_tree_git_hl = 1
g.nvim_tree_add_trailing = 1
g.nvim_tree_ignore = { ".git", "node_modules", ".cache", ".DS_Store", ".netrwhist" }
g.nvim_tree_special_files = {}
g.nvim_tree_disable_default_keybindings = 1

local tree_cb = require'nvim-tree.config'.nvim_tree_callback
vim.g.nvim_tree_bindings = {
  { key = {"<CR>", "o", "<2-LeftMouse>"}, cb = tree_cb("edit") },
  { key = "<C-v>",                        cb = tree_cb("vsplit") },
  { key = "R",                            cb = tree_cb("refresh") },
  { key = "a",                            cb = tree_cb("create") },
  { key = "d",                            cb = tree_cb("remove") },
  { key = "r",                            cb = tree_cb("rename") },
}
