"""""""""""""""""""""""""""""""""""""""""""""
" Generic
"""""""""""""""""""""""""""""""""""""""""""""

" fix the fucking stupid yank/paste default behavior to be not stupid
xnoremap <silent> P p:call setreg('"', getreg('0'), getregtype('0'))<CR>

" keep visual selection after indenting
vnoremap < <gv
vnoremap > >gv

" <leader>v to split pane vertically, switch to new pane, open fzf to put new
" file into new pane
nmap <leader>v :vnew<CR>:Files<CR>

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

" in insert mode, escape should do the following:
" - if a coc popup is visible, just close the popup and remain in Insert mode
" - otherwise, act normal (go to Normal mode)
inoremap <expr> <Esc> pumvisible() ? '<c-y>' : '<Esc>'



"""""""""""""""""""""""""""""""""""""""""""""
" vim-commentary
"""""""""""""""""""""""""""""""""""""""""""""

" ctrl+/ to toggle comment
map <silent> <C-_> :Commentary<CR>



"""""""""""""""""""""""""""""""""""""""""""""
" fzf.vim
"""""""""""""""""""""""""""""""""""""""""""""

" <leader>f to global fuzzy text search
nmap <silent> <leader>f :SearchForText<CR>

" ctrl+p to fzf
nmap <silent> <C-P> :Files<CR>


"""""""""""""""""""""""""""""""""""""""""""""
" NERDTree
"""""""""""""""""""""""""""""""""""""""""""""

" F3 to toggle NERDTree
nmap <silent> <F3> :NERDTreeToggle<CR>


"""""""""""""""""""""""""""""""""""""""""""""
" coc.nvim
"""""""""""""""""""""""""""""""""""""""""""""

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)
nmap <F2> <Plug>(coc-rename)

" use tab to cycle suggestions
inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"
" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
nnoremap <silent> K :call <SID>show_documentation()<CR>
