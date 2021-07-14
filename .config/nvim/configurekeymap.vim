"""""""""""""""""""""""""""""""""""""""""""""
" Generic
"""""""""""""""""""""""""""""""""""""""""""""

" jk as second mapping to <ESC>
imap jk <Esc>

" keep visual selection after indenting
vnoremap < <gv
vnoremap > >gv

" <leader>v to split pane vertically, switch to new pane, open file search to put new
" file into new pane
nmap <silent> <leader>v :vsplit<CR>:Files<CR>

" <leader>b to split pane vertically, switch to new pane, and search already
" opened buffers and put the selected buffer into the new pane
nmap <silent> <leader>b :vsplit<CR>:Buffers<CR>

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

" <leader>c to toggle comment
map <silent> <leader>c :Commentary<CR>


"""""""""""""""""""""""""""""""""""""""""""""
" fzf
"""""""""""""""""""""""""""""""""""""""""""""

" ff or ctrl+p to search for files
nnoremap ff :Files<CR>

" ft to search for text
nnoremap ft :Rg<CR>

" fb to search buffers
nnoremap fb :Buffers<CR>

" fh to search recents
nnoremap fh :History<CR>

" ctrl+f to fuzzy find in current buffer
nnoremap <C-f> :BLines<CR>


"""""""""""""""""""""""""""""""""""""""""""""
" nvim-tree
"""""""""""""""""""""""""""""""""""""""""""""

" F3 to toggle tree
nmap <silent> <F3> :NvimTreeToggle<CR>


"""""""""""""""""""""""""""""""""""""""""""""
" coc.nvim
"""""""""""""""""""""""""""""""""""""""""""""

" Quick fix
nmap F <Plug>(coc-fix-current)

" Code Actions
nmap ca <Plug>(coc-codeaction)

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)
nmap <F2> <Plug>(coc-rename)

" use tab to cycle suggestions
inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"
" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm()
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
" Dashboard Session
"""""""""""""""""""""""""""""""""""""""""""""

nmap <Leader>ss :<C-u>SessionSave<CR>
nmap <Leader>sl :<C-u>SessionLoad<CR>


"""""""""""""""""""""""""""""""""""""""""""""
" nvim-bufferline window movement
"""""""""""""""""""""""""""""""""""""""""""""

" ctrl+tab and shift+tab for cycling buffer tabs
nnoremap <silent><C-tab> :BufferLineCycleNext<CR>
nnoremap <silent><S-tab> :BufferLineCyclePrev<CR>
nnoremap <silent>W :exec 'bdelete ' . bufname()<CR>


"""""""""""""""""""""""""""""""""""""""""""""
" Window/pane movement
"""""""""""""""""""""""""""""""""""""""""""""

nnoremap H <C-w>h
nnoremap J <C-w>j
nnoremap K <C-w>k
nnoremap L <C-w>l
