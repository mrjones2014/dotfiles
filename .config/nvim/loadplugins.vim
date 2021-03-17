call plug#begin(stdpath('data') . '/plugged')

Plug 'mrjones2014/vim-code-dark'

Plug 'sheerun/vim-polyglot'

Plug 'tpope/vim-sleuth'

Plug 'tpope/vim-commentary'

Plug 'tpope/vim-fugitive'

Plug 'APZelos/blamer.nvim'

Plug 'blueyed/vim-diminactive'

Plug 'preservim/nerdtree'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'dense-analysis/ale'

Plug 'ryanoasis/vim-devicons'

Plug 'mhinz/vim-startify'

Plug 'Yggdroot/indentLine'

Plug 'farmergreg/vim-lastplace'

Plug 'jiangmiao/auto-pairs'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

call plug#end()
