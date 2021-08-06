-- run Prettier
vim.cmd('command! -nargs=0 Prettier :lua vim.lsp.buf.formatting()<CR>')

-- alias git to Git for vim-fugitive
vim.cmd('cnoreabbrev git Git')
