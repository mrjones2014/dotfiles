-- run Prettier
vim.cmd('command! -nargs=0 Prettier :CocCommand prettier.formatFile')

-- alias git to Git for vim-fugitive
vim.cmd('cnoreabbrev git Git')

-- override :Rg with some extra options
vim.cmd('command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case --ignore-file ~/.config/.ignore ".shellescape(<q-args>), 1, {"options": "--delimiter : --nth 4.."}, <bang>0)')
