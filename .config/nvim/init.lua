-- jump to last cursor position in file
vim.cmd([[
  autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif
]])

require('disable-builtins')
require('settings')
require('custom-filetypes')
require('configure-trailing-whitespace')
require('plugins')
require('lsp-init')
