-- TODO couldn't quite get this working with a lua equivalent
vim.cmd([[
  augroup CustomFileTypeDetection
    au! BufEnter *.html set syntax=gohtmltmpl
    au! FileType html set syntax=gohtmltmpl
    au! FileType fish compiler fish
    au! FileType json set conceallevel=0
  augroup END
]])
