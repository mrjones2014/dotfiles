" :Prettier => :CocCommand prettier.formatFile
command! -nargs=0 Prettier :CocCommand prettier.formatFile

" alias :git to :Git for vim-fugitive
cnoreabbrev git Git

" :Jest => Run jest for current project
command! -nargs=0 Jest :call  CocAction('runCommand', 'jest.projectTest')
cnoreabbrev jest Jest

" :JestCurrent => Run jest for current file
command! -nargs=0 JestCurrent :call  CocAction('runCommand', 'jest.fileTest', ['%'])
cnoreabbrev jc JestCurrent

" F2 to refactor rename symbol
nmap <F2> <Plug>(coc-rename)

" ctrl+/ to toggle comment
map <C-_> :Commentary<CR>

" ctrl+j to move line up
map <C-j> :m -2<CR>
" ctrl+k to move line down
map <C-k> :m +1<CR>

" ctrl+s to save all
map <C-s> :wa<CR>

" ctrl+q to close all
map <C-q> :qa<CR>

" remap ctrl+p to fzf
nmap <C-P> :Files<CR>

" <leader>q to close buffer
map <leader>q :q<CR>
