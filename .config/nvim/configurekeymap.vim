"""""""""""""""""""""""""""""""""""""""""""""
" Generic
"""""""""""""""""""""""""""""""""""""""""""""

" fix the fucking stupid yank/paste default behavior to be not stupid
xnoremap <silent> P p:call setreg('"', getreg('0'), getregtype('0'))<CR>

" keep visual selection after indenting
vnoremap < <gv
vnoremap > >gv

" <leader>v to split pane vertically, switch to new pane, open file search to put new
" file into new pane
nmap <silent> <leader>v :vnew<CR>:FindFiles<CR>

" <leader>b to split pane vertically, switch to new pane, and search already
" opened buffers and put the selected buffer into the new pane
nmap <silent> <leader>b :vnew<CR>:Telescope buffers<CR>

" ctrl+j to move line up
map <silent> <C-k> :m -2<CR>
" ctrl+k to move line down
map <silent> <C-j> :m +1<CR>

" space => q to close buffer
nmap <silent> <Space>q :bp<CR>:bd #<CR>

" <leader>q to close all
nmap <leader>q :qa<CR>

" <leader>s or <leader>w to save all
nmap <leader>s :wa<CR>
nmap <leader>w :wa<CR>

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
" vim-obsession
"""""""""""""""""""""""""""""""""""""""""""""

nmap <leader><leader> :Obsession<CR>


"""""""""""""""""""""""""""""""""""""""""""""
" telescope.nvim
"""""""""""""""""""""""""""""""""""""""""""""

" ff or ctrl+p to search for files
nnoremap ff :FindFiles<CR>

" ft to search for text
nnoremap ft :lua require'telescope'.extensions.fzf_writer.grep()<CR>

" fb to search buffers
nnoremap fb :Telescope buffers<CR>

" fh to search help tags
nnoremap fh :Telescope help_tags<CR>

" fc to search commands
nnoremap fc :Telescope commands<CR>

" ctrl+f to fuzzy find in current buffer
nnoremap <C-f> :Telescope current_buffer_fuzzy_find<CR>


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



"""""""""""""""""""""""""""""""""""""""""""""
" airline/window management
"""""""""""""""""""""""""""""""""""""""""""""

" Go to tab by number
nmap <silent> <leader>1 <Plug>AirlineSelectTab1
nmap <silent> <leader>2 <Plug>AirlineSelectTab2
nmap <silent> <leader>3 <Plug>AirlineSelectTab3
nmap <silent> <leader>4 <Plug>AirlineSelectTab4
nmap <silent> <leader>5 <Plug>AirlineSelectTab5
nmap <silent> <leader>6 <Plug>AirlineSelectTab6
nmap <silent> <leader>7 <Plug>AirlineSelectTab7
nmap <silent> <leader>8 <Plug>AirlineSelectTab8
nmap <silent> <leader>9 <Plug>AirlineSelectTab9

" Go to window by number
nmap <Space>1 :1 wincmd w<CR>
nmap <Space>2 :2 wincmd w<CR>
nmap <Space>3 :3 wincmd w<CR>
nmap <Space>4 :4 wincmd w<CR>
nmap <Space>5 :5 wincmd w<CR>
nmap <Space>6 :6 wincmd w<CR>
nmap <Space>7 :7 wincmd w<CR>
nmap <Space>8 :8 wincmd w<CR>
nmap <Space>9 :9 wincmd w<CR>
