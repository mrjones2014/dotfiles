autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif

autocmd FileType json :set conceallevel=0

augroup TerminalBuffers
  autocmd!
  autocmd TermOpen * setlocal nonumber norelativenumber | startinsert
  autocmd TermClose * Bdelete!
augroup END
