" Found on: https://discourse.gohugo.io/t/vim-syntax-highlighting-for-hugo-html-templates/19398/8
function DetectGoHtmlTmpl()
    if expand('%:e') == "html" && search("{{") != 0
        set filetype=gohtmltmpl
    endif
endfunction

function StripTrailingWhitespace()
    " dont strip on these filetypes
    if &ft =~ 'vim'
        return
    endif
    %s/\s\+$//e
endfunction

function RemapCustomKeys()
    " F2 to refactor rename symbol
    nmap <F2> <Plug>(coc-rename)

    " ctrl+/ to toggle comment
    map <C-_> :Commentary<CR>
endfunction

function AddCustomCommands()
    command! -nargs=0 Prettier :CocCommand prettier.formatFile
endfunction

function AddCustomFiletypeDetection()
    augroup filetypedetect
        au! BufRead,BufNewFile * call DetectGoHtmlTmpl()
    augroup END
endfunction

function AddTabIndentGuides()
    set listchars=tab:\|\ 
    set list
endfunction

function AddCustomCocConfig()
    let g:coc_config_home = '~/.SpaceVim.d/'
    let g:coc_global_extensions = [
        \'coc-tsserver',
        \'coc-prettier',
        \'coc-json',
        \'coc-html',
        \'coc-css',
    \]
endfunction

function AddCustomVimConfig()
    " ensure 15 line buffer above and below cursor
    set scrolloff=15

    " highlight redundant trailing whitespace with colorscheme's error color
    match Error /\s\+$/

    " strip trailing whitespace on save
    autocmd BufWritePre * call StripTrailingWhitespace()
endfunction

function myspacevim#before() abort
endfunction

function myspacevim#after() abort
    let $FZF_DEFAULT_COMMAND ='ag --hidden --ignore .git -g ""'
    call AddCustomCocConfig()
    call AddCustomCommands()
    call AddCustomFiletypeDetection()
    call RemapCustomKeys()
    call AddTabIndentGuides()
    call AddCustomVimConfig()
endfunction

