vim.cmd([[
  augroup CustomFileTypeDetection
    autocmd! BufRead,BufNewFile,BufWritePost * :lua require('filetype-utils').detect_filetypes()
    autocmd! FileType Fish compiler fish
    autocmd! FileType json set conceallevel=0
  augroup END
]])
