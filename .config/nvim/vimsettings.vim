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

" disable ALE LSP because we're using coc
let g:ale_disable_lsp = 1

" leader key
let mapleader = "\\"

" enable mouse cursor movement
set mouse=a

" Minimal automatic indenting for any filetype.
set autoindent

" Proper backspace behavior.
set backspace=indent,eol,start

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

" Hugo template filetype detection
" augroup filetypedetect
" 	au! BufRead,BufNewFile * call DetectGoHtmlTmpl()
" augroup END

" Possibility to have more than one unsaved buffers.
set hidden

" show line numbers
set number

" keep visual selection after indenting
vnoremap < <gv
vnoremap > >gv

" persistent undo
set undofile
set undodir=~/.vim/undodir

" use system clipboard
set clipboard=unnamedplus

" command-line autocompletion
set wildmenu

" disable line wrapping
set nowrap
