" Found on: https://discourse.gohugo.io/t/vim-syntax-highlighting-for-hugo-html-templates/19398/8
function DetectGoHtmlTmpl()
    if expand('%:e') == "html" && search("{{") != 0
        set filetype=gohtmltmpl
    endif
endfunction

function myspacevim#before() abort
    let g:coc_config_home = '~/.SpaceVim.d/'
    let g:coc_global_extensions = [
        \'coc-tsserver',
        \'coc-prettier',
        \'coc-json',
        \'coc-html',
    \]
endfunction

function myspacevim#after() abort
    let g:coc_config_home = '~/.SpaceVim.d/'
    let $FZF_DEFAULT_COMMAND ='ag --hidden --ignore .git -g ""'
    " highlight redundant trailing whitespace with colorscheme's error color
    match Error /\s\+$/
    set listchars=tab:\|\ 
    set list
    command! -nargs=0 Prettier :CocCommand prettier.formatFile
    augroup filetypedetect
        au! BufRead,BufNewFile * call DetectGoHtmlTmpl()
    augroup END
endfunction

