" Found on: https://discourse.gohugo.io/t/vim-syntax-highlighting-for-hugo-html-templates/19398/8
function! s:DetectGoHtmlTmpl()
    if expand('%:e') == "html" && search("{{") != 0
        set filetype=gohtmltmpl
    endif
endfunction

function! s:DetectFiletypeFromShebangLine()
    " if the first line is not a shebang, do nothing
    if getline(1) !~ "#!/"
        return
    endif

    if getline(1) =~ "zsh"
        setfiletype zsh
    endif

    if getline(1) =~ "bash"
        setfiletype bash
    endif

    if getline(0) =~ "fish"
        setfiletype fish
    endif
endfunction

" Hugo template filetype detection
" This is used with the vim-go plugin
" which adds syntax highlighting and completion
" for the Go templating syntax while also loading
" the stuff that comes with the normal HTML filetype
augroup filetypedetect
    au! BufRead,BufNewFile,BufWritePost * call <SID>DetectGoHtmlTmpl()
    au! BufRead,BufNewFile,BufWritePost * call <SID>DetectFiletypeFromShebangLine()
augroup END
