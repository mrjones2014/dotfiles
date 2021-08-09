-- TODO couldn't quite get this working with a lua equivalent
vim.cmd([[
  function SetGoHtmlOpts()
    if expand('%:e') == 'html' && search('{{') != 0
      setlocal syntax=gohtmltmpl
      setlocal filetype=gohtmltmpl
      setlocal commentstring={{/*\ %s\ */}}
    endif
  endfunction
  augroup CustomFileTypeDetection
    au! BufEnter *.html :call SetGoHtmlOpts()
    au! FileType html :call SetGoHtmlOpts()
    au! FileType json set conceallevel=0
  augroup END
]])
