return require('packer').startup(function()
  -- Packer can manage itself
  use('wbthomason/packer.nvim')

  -- Themes
  use('folke/tokyonight.nvim')
  use('Pocco81/Catppuccino.nvim')

  -- Dependencies of other plugins
  use('nvim-lua/plenary.nvim')
  use('nvim-lua/popup.nvim')

  -- Editing enhancements and tools
  use('windwp/nvim-autopairs')
  use('AndrewRadev/tagalong.vim')
  use('matze/vim-move')
  use('nvim-telescope/telescope.nvim')
  use({ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' })
  use('nvim-telescope/telescope-symbols.nvim')
  use('numtostr/FTerm.nvim')
  use({ 'iamcco/markdown-preview.nvim', ft = 'markdown', run = 'cd app && yarn install' })
  use('David-Kunz/treesitter-unit')

  -- Tim Pope plugins
  use('tpope/vim-sleuth')
  use('tpope/vim-commentary')
  use('tpope/vim-eunuch')

  -- LSP + syntax
  use('neovim/nvim-lspconfig')
  use('ray-x/lsp_signature.nvim')
  use('hrsh7th/nvim-compe')
  use('onsails/lspkind-nvim')
  use('ckipp01/stylua-nvim')
  use({ 'dag/vim-fish', ft = 'fish' })
  use('mattn/emmet-vim')
  use('folke/trouble.nvim')
  use('fatih/vim-go') -- just used for gohtmltmpl syntax highlighting
  use('p00f/nvim-ts-rainbow')
  use({ 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' })
  use({ 'nvim-treesitter/playground', cmd = { 'TSPlaygroundToggle' } })

  -- UI + utils
  use('kyazdani42/nvim-web-devicons')
  use({ 'yamatsum/nvim-nonicons', requires = { 'kyazdani42/nvim-web-devicons' } })
  use({
    'kyazdani42/nvim-tree.lua',
    cmd = { 'NvimTreeToggle' },
    config = function()
      local tree_cb = require('nvim-tree.config').nvim_tree_callback
      vim.g.nvim_tree_bindings = {
        { key = { '<CR>', 'o', '<2-LeftMouse>' }, cb = tree_cb('edit') },
        { key = '<C-v>', cb = tree_cb('vsplit') },
        { key = 'R', cb = tree_cb('refresh') },
        { key = 'a', cb = tree_cb('create') },
        { key = 'd', cb = tree_cb('remove') },
        { key = 'r', cb = tree_cb('rename') },
        { key = '.', cb = tree_cb('cd') },
      }
    end,
  })
  use('lukas-reineke/indent-blankline.nvim')
  use('farmergreg/vim-lastplace')
  use('airblade/vim-gitgutter')
  use('hoob3rt/lualine.nvim')
  use('akinsho/nvim-bufferline.lua')
  use('norcalli/nvim-colorizer.lua')
  use('glepnir/dashboard-nvim')
  use('f-person/git-blame.nvim')
  use('folke/todo-comments.nvim')
  -- yaclt
  use('~/git/yaclt.nvim')
end)
