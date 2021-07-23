return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- This is used by lots of other lua plugins so load this up here
  use 'nvim-lua/plenary.nvim'

  -- Editing enhancements and tools
  use 'windwp/nvim-autopairs'
  use 'AndrewRadev/tagalong.vim'
  use 'matze/vim-move'
  use {'junegunn/fzf', dir = '~/.fzf', run = './install --all' }
  use 'junegunn/fzf.vim'
  use {'iamcco/markdown-preview.nvim', ft = 'markdown', run = 'cd app && yarn install'}

  -- Tim Pope plugins
  use 'tpope/vim-sleuth'
  use 'tpope/vim-commentary'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-eunuch'

  -- LSP + syntax
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-compe'
  use 'onsails/lspkind-nvim'
  use 'dag/vim-fish'
  use 'neoclide/jsonc.vim'
  use 'sheerun/vim-polyglot'
  use 'mattn/emmet-vim'
  use {'prettier/vim-prettier', run = 'yarn install'}
  use 'folke/trouble.nvim'

  -- UI + utils
  use 'nvim-lua/popup.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'kyazdani42/nvim-tree.lua'
  use 'thaerkh/vim-indentguides'
  use 'farmergreg/vim-lastplace'
  use 'airblade/vim-gitgutter'
  use 'hoob3rt/lualine.nvim'
  use 'akinsho/nvim-bufferline.lua'
  use 'glepnir/dashboard-nvim'

  -- Theme
  use 'projekt0n/github-nvim-theme'
end)
