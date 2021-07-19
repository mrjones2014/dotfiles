return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Editing enhancements and tools
  use 'windwp/nvim-autopairs'
  use 'AndrewRadev/tagalong.vim'
  use 'matze/vim-move'
  use {'junegunn/fzf', dir = '~/.fzf', run = './install --all' }
  use 'junegunn/fzf.vim'
  use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = "MarkdownPreview"}

  -- Tim Pope plugins
  use 'tpope/vim-sleuth'
  use 'tpope/vim-commentary'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-eunuch'

  -- LSP + syntax
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-compe'
  use 'dag/vim-fish'
  use 'neoclide/jsonc.vim'
  use 'sheerun/vim-polyglot'
  use 'mattn/emmet-vim'
  use 'sbdchd/neoformat'
  use 'jose-elias-alvarez/nvim-lsp-ts-utils'
  use 'folke/trouble.nvim'

  -- UI + utils
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
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
