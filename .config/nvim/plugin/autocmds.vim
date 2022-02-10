autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif

autocmd FileType json :set conceallevel=0

" quit Neovim if neo-tree is the only remaining buffer
autocmd WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&filetype") == "neo-tree" | q | endif

augroup TerminalBuffers
  autocmd!
  autocmd TermOpen * setlocal nonumber norelativenumber | startinsert
  autocmd TermClose * Bdelete!
augroup END
