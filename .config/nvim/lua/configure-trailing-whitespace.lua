vim.cmd([[
  highlight TrailingWhitespace ctermbg=red guibg=red
  match TrailingWhitespace /\s\+$/

  function TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
  endfunction

  " trim trailing whitspace on save
  autocmd BufWritePre * :call TrimWhitespace()
]])
