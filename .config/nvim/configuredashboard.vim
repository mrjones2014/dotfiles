let g:dashboard_custom_header = [
\' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
\' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
\' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
\' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
\' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
\' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
\]

let g:dashboard_custom_section={
  \ 'session': {
      \ 'description': ['  Load Last Session   <leader>sl'],
      \ 'command': 'SessionLoad'
    \},
  \ 'recents': {
      \ 'description': ['  Search Recent Files         fh'],
      \ 'command': 'History'
  \ },
  \ 'files': {
      \ 'description': ['  Search Files                ff'],
      \ 'command': 'Files'
  \ }
\ }

let g:dashboard_custom_footer = { }
