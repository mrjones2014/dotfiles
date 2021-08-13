local lsp = require('lspconfig')

require('load-all')(os.getenv('HOME') .. '/.config/nvim/lua/lsp')

vim.cmd('command! Format :lua require("lsp.utils").formatDocument()')
vim.cmd([[
  augroup fmt
    autocmd!
    autocmd BufWritePre * Format
  augroup END
]])
