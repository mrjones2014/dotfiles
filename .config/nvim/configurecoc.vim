let g:coc_global_extensions = [
  \'coc-tsserver',
  \'coc-prettier',
  \'coc-json',
  \'coc-html',
  \'coc-css',
  \'coc-jest',
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
