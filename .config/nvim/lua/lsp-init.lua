local lsp = require('lspconfig')

require('lsp/typescript')
require('lsp/html')
require('lsp/css')
require('lsp/json')
require('lsp/diagnostics')

vim.cmd('command! Format :lua require("lsp/utils").formatDocument()')
vim.cmd([[
  augroup fmt
    autocmd!
    autocmd BufWritePre * Format
  augroup END
]])
