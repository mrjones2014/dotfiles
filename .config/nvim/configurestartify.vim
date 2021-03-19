" turn off dumb startify autochdir
let g:startify_change_to_dir = 0

" detect if it's a git project
silent! !git rev-parse --is-inside-work-tree

if v:shell_error == 0
	" we are in a git project
	" just show the project name
	let g:startify_custom_header = ['', 'Project:', '    ' . fnamemodify(getcwd(), ':t')]
else
	" otherwise just show the full path
	let g:startify_custom_header = ['', 'Directory:', '    ' . getcwd()]
endif
