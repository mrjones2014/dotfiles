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

set nocompatible

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

" strip trailing whitespace on save
autocmd BufWritePre * call StripTrailingWhitespace()

" add hyphen as keyword for full SCSS support
set iskeyword+=@-@
set iskeyword+=-

" set tab width
" shiftwidth=0 makes it default to same as tabstop
set shiftwidth=0
set tabstop=2
set expandtab "this gets overridden by vim sleuth when necessary, but use spaces by default
" indent guides for when using tabs -- the indentLine plugin only works for
" spaces
set listchars=tab:\|\ 
set list

"enable line wrapping with left and right cursor movement
set whichwrap+=<,>,h,l,[,]

" show the sign column always so the layout doesn't shift when signs are
" added
set signcolumn=yes

" Hugo template filetype detection
" This is used with the vim-go plugin
" which adds syntax highlighting and completion
" for the Go templating syntax while also loading
" the stuff that comes with the normal HTML filetype
augroup filetypedetect
	au! BufRead,BufNewFile,BufWritePost * call DetectGoHtmlTmpl()
augroup END

" Enable more than one unsaved buffer
set hidden

" show line numbers
set number

" persistent undo
set undofile
set undodir=~/.vim/undodir

" use system clipboard
set clipboard=unnamedplus

" command-line autocompletion
set wildmenu

" disable line wrapping
set nowrap

" set default file encoding
set enc=utf-8
set encoding=utf-8
set fileencoding=utf-8

" if using vimdiff, show vertically
set diffopt=vertical
