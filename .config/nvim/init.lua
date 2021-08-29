-- jump to last cursor position in file
vim.cmd([[
  autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif
]])

require('disable-builtins')
require('settings')
require('keybinds')
require('custom-filetypes')
require('configure-trailing-whitespace')
require('lsp-init')
require('plugins')
