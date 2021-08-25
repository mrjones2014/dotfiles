return require('packer').startup(function()
  -- Packer can manage itself
  use('wbthomason/packer.nvim')

  -- Themes
  use(require('plugins.configure-catppuccino'))

  -- Dependencies of other plugins
  use('nvim-lua/plenary.nvim')
  use('nvim-lua/popup.nvim')

  -- Editing enhancements and tools
  use(require('plugins.configure-autopairs'))
  use({ 'AndrewRadev/tagalong.vim', ft = { 'html', 'gohtmltmpl' } })
  use('matze/vim-move')
  use(require('plugins.configure-telescope'))
  use(require('plugins.configure-telescope-fzf-native'))
  use('nvim-telescope/telescope-symbols.nvim')
  use(require('plugins.configure-fterm'))
  use({ 'iamcco/markdown-preview.nvim', ft = 'markdown', run = 'cd app && yarn install' })

  -- Tim Pope plugins
  use('tpope/vim-sleuth')
  use('tpope/vim-commentary')
  use('tpope/vim-eunuch')

  -- LSP + syntax
  use('neovim/nvim-lspconfig')
  use('ray-x/lsp_signature.nvim')
  use(require('plugins.configure-compe'))
  use(require('plugins.configure-lspkind'))
  use('ckipp01/stylua-nvim')
  use({ 'dag/vim-fish', ft = 'fish' })
  use('mattn/emmet-vim')
  use(require('plugins.configure-trouble'))
  use('fatih/vim-go') -- just used for gohtmltmpl syntax highlighting
  use('p00f/nvim-ts-rainbow')
  use(require('plugins.configure-treesitter'))
  use({ 'nvim-treesitter/playground', cmd = { 'TSPlaygroundToggle' } })

  -- UI + utils
  use('kyazdani42/nvim-web-devicons')
  use({ 'yamatsum/nvim-nonicons', requires = { 'kyazdani42/nvim-web-devicons' } })
  use(require('plugins.configure-nvimtree'))
  use(require('plugins.configure-indent-blankline'))
  use('farmergreg/vim-lastplace')
  use('airblade/vim-gitgutter')
  use(require('plugins.configure-lualine'))
  use(require('plugins.configure-bufferline'))
  use(require('plugins.configure-colorizer'))
  use(require('plugins.configure-dashboard'))
  use(require('plugins.configure-git-blame'))
  use(require('plugins.configure-todo-comments'))
  -- yaclt
  use('~/git/yaclt.nvim')
end)
