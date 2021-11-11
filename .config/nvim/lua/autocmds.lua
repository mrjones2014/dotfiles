-- jump to last cursor position in file
vim.cmd([[
  autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif
]])

-- disable concealing on json files
vim.cmd('autocmd FileType json :set conceallevel=0')

-- highlight trailing whitespace and trim it on save
vim.cmd([[
  function! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
  endfunction

  function! SetupTrailingWhitespaceHighlight()
    highlight TrailingWhitespace ctermbg=red guibg=red
    match TrailingWhitespace /\s\+$/
  endfunction

  augroup WhitespaceHandling
    autocmd VimEnter * :call SetupTrailingWhitespaceHighlight()
    autocmd BufWritePre * :call TrimWhitespace()
  augroup END
]])
