let g:coc_global_extensions = [
  \'coc-tsserver',
  \'coc-prettier',
  \'coc-json',
  \'coc-html',
  \'coc-css',
  \'coc-emmet',
  \'coc-vimlsp',
  \'coc-sh',
\]

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

let s:format_on_save_filetypes = [
  \'css',
  \'scss',
  \'markdown',
  \'typescript',
  \'typescriptreact',
  \'javascript',
  \'javascriptreact',
  \'html',
  \'gohtmltmpl',
  \'json'
\]

function s:FormatOnSave()
  if (index(s:format_on_save_filetypes, &ft) < 0)
    return
  endif

  let save_cursor = getpos(".")
  call CocAction('runCommand', 'editor.action.organizeImport')
  sleep 100m
  call CocAction('format')
  call setpos(".", save_cursor)
endfunction

autocmd BufWritePre * silent call <SID>FormatOnSave()

" leaving coc keybinds in here till I move to LSP
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
