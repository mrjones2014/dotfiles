let g:coc_global_extensions = [
	\'coc-tsserver',
	\'coc-prettier',
	\'coc-json',
	\'coc-html',
	\'coc-css',
	\'coc-jest',
	\'coc-emmet',
\]

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
