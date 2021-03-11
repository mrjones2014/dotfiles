"
" UTILS
"

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

"
" CONFIG
"

function RemapCustomKeys()
    " F2 to refactor rename symbol
    nmap <F2> <Plug>(coc-rename)

    " ctrl+/ to toggle comment
    map <C-_> :Commentary<CR>

    " ctrl+j to move line up
    map <C-j> :m -2<CR>
    " ctrl+k to move line down
    map <C-k> :m +1<CR>
endfunction

function AddCustomCommands()
    " :Prettier => :CocCommand prettier.formatFile
    command! -nargs=0 Prettier :CocCommand prettier.formatFile

    " alias :git to :Git for vim-fugitive
    cnoreabbrev git Git

    " :Jest => Run jest for current project
    command! -nargs=0 Jest :call  CocAction('runCommand', 'jest.projectTest')
    cnoreabbrev jest Jest

    " :JestCurrent => Run jest for current file
    command! -nargs=0 JestCurrent :call  CocAction('runCommand', 'jest.fileTest', ['%'])
    cnoreabbrev jc JestCurrent
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

function AddCustomVimConfig()
    " ensure 8 line buffer above and below cursor
    set scrolloff=8

    " highlight redundant trailing whitespace with colorscheme's error color
    match Error /\s\+$/

    " strip trailing whitespace on save
    autocmd BufWritePre * call StripTrailingWhitespace()

    " add hyphen as keyword for full SCSS support
    set iskeyword+=@-@
    set iskeyword+=-

    " set tab width
    " shiftwidth=0 makes it default to same as tabstop
    set shiftwidth=0
    set tabstop=2

    " enable line wrapping with left and right cursor movement
    set whichwrap+=<,>,h,l,[,]

    " show the sign column always so the layout doesn't shift when signs are
    " added
    set signcolumn=yes
endfunction

function myspacevim#before() abort
    " for some reason these COC configs have to go here
    " and don't work if you move them to a function
    " and call the function ¯\_(ツ)_/¯
    let g:coc_config_home = '~/.SpaceVim.d/'
    let g:coc_global_extensions = [
        \'coc-tsserver',
        \'coc-prettier',
        \'coc-json',
        \'coc-html',
        \'coc-css',
        \'coc-jest',
    \]
    let g:blamer_enabled = 1
    let g:blamer_delay = 200
    let g:blamer_show_in_insert_modes = 0
endfunction

function myspacevim#after() abort
    let g:coc_config_home = '~/.SpaceVim.d/'
    highlight Blamer guifg=grey
    let $FZF_DEFAULT_COMMAND ='ag --hidden --ignore .git -g ""'
    call AddCustomCommands()
    call AddCustomFiletypeDetection()
    call RemapCustomKeys()
    call AddTabIndentGuides()
    call AddCustomVimConfig()
endfunction

