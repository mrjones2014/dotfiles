-- TODO couldn't quite get this working with a lua equivalent
vim.cmd([[
  " Found on: https://discourse.gohugo.io/t/vim-syntax-highlighting-for-hugo-html-templates/19398/8
  function! DetectCustomFiletype()
      if expand('%:e') == "html" && search("{{") != 0
          set filetype=gohtmltmpl
          return
      endif

      " if the first line is not a shebang, do nothing
      if getline(1) !~ "#!/"
          return
      endif

      if getline(1) =~ "zsh"
          set filetype=zsh
      endif

      if getline(1) =~ "bash"
          set filetype=bash
      endif

      if getline(0) =~ "fish"
          set filetype=fish
      endif
  endfunction

  augroup CustomFileTypeDetection
    au! BufRead,BufNewFile,BufWritePost * call DetectCustomFiletype()
    au! FileType fish compiler fish
    au! FileType json set conceallevel=0
  augroup END
]])
