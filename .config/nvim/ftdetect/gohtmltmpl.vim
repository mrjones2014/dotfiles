function DetectGoHtmlTmpl()
  if expand('%:e') == 'html' && search('{{') != 0
    setlocal syntax=gohtmltmpl
    setlocal filetype=gohtmltmpl
    setlocal commentstring={{/*\ %s\ */}}
  endif
endfunction

augroup GoHtmlTmplDetect
  au! BufEnter *.html :call DetectGoHtmlTmpl()
  au! FileType html :call DetectGoHtmlTmpl()
augroup END
