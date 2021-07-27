-- TODO couldn't quite get this working with a lua equivalent
vim.cmd([[
  function SetGoHtmlOpts()
    setlocal syntax=gohtmltmpl
    setlocal commentstring={{/*\ %s\ */}}
  endfunction
  augroup CustomFileTypeDetection
    au! BufEnter *.html :call SetGoHtmlOpts()
    au! FileType html :call SetGoHtmlOpts()
    au! FileType fish compiler fish
    au! FileType json set conceallevel=0
  augroup END
]])
