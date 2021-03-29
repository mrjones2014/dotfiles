if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent execute "!curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  echoerr "Installed vim-plug -- run :PlugInstall and restart nvim"
  finish
endif

call plug#begin(stdpath('data') . '/plugged')

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" themes etc.
""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'joshdick/onedark.vim'


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tim Pope gets his own section
""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-eunuch'


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" LSP/Syntax/coding helpers
""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'dense-analysis/ale'
Plug 'jiangmiao/auto-pairs'
" basically just using this for the Go HTML Template filetype niceties
Plug 'fatih/vim-go'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" UI/tools
""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'mrjones2014/vim-make.vim'
Plug 'APZelos/blamer.nvim'
Plug 'blueyed/vim-diminactive'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'mhinz/vim-startify'
Plug 'thaerkh/vim-indentguides'
Plug 'farmergreg/vim-lastplace'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

call plug#end()
