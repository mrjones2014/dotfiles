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
