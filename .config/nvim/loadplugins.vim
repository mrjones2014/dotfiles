let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data') . '/plugged')

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" themes
""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'projekt0n/github-nvim-theme'


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tim Pope gets his own section
""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-obsession'


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" LSP/Syntax/coding helpers
""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'dense-analysis/ale'
Plug 'windwp/nvim-autopairs'
Plug 'dag/vim-fish'
Plug 'fatih/vim-go'
Plug 'neoclide/jsonc.vim'
Plug 'AndrewRadev/tagalong.vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'matze/vim-move'


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tools & Utils
""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" UI
""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'TaDaa/vimade'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'mhinz/vim-startify'
Plug 'thaerkh/vim-indentguides'
Plug 'farmergreg/vim-lastplace'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'

call plug#end()
