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

" keep visual selection after indenting
vnoremap < <gv
vnoremap > >gv

" ctrl+/ to toggle comment
map <C-_> :Commentary<CR>

" <leader>v to split pane vertically
nmap <leader>v :vsplit<CR>

" ctrl+j to move line up
map <silent> <C-j> :m -2<CR>
" ctrl+k to move line down
map <silent> <C-k> :m +1<CR>

" space => q to close buffer
nmap <silent> <Space>q :bp<CR>:bd #<CR>

" <leader>q to close all
nmap <leader>q :qa<CR>

" <leader>s to save all
nmap <leader>s :wa<CR>
