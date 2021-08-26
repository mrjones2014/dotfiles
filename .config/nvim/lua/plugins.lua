return require('packer').startup(function()
  -- Packer can manage itself
  use('wbthomason/packer.nvim')

  -- Dependencies of other plugins
  use('nvim-lua/plenary.nvim')
  use('nvim-lua/popup.nvim')

  -- Themes
  use(require('configure.catppuccino'))

  -- Editing enhancements and tools
  use(require('configure.vim-move'))
  use(require('configure.telescope'))
  use(require('configure.telescope-fzf-native'))
  use(require('configure.autopairs'))
  use(require('configure.tagalong'))
  use(require('configure.fterm'))
  use(require('configure.markdown-preview'))
  use(require('configure.kommentary'))

  -- Tim Pope plugins
  -- TODO replace these with lua plugins and lazy load them?
  use('tpope/vim-sleuth')
  use('tpope/vim-eunuch')

  -- LSP + syntax
  use(require('configure.lspconfig'))
  use(require('configure.stylua'))
  use(require('configure.emmet'))
  use(require('configure.vim-go')) -- just used for gohtmltmpl syntax highlighting
  use(require('configure.compe'))
  use(require('configure.lspkind'))
  use(require('configure.vim-fish'))
  use(require('configure.trouble'))
  use(require('configure.treesitter'))
  use(require('configure.treesitter-playground'))

  -- UI + utils
  use(require('configure.gitgutter'))
  use(require('configure.nonicons'))
  use(require('configure.nvimtree'))
  use(require('configure.indent-blankline'))
  use(require('configure.lualine'))
  use(require('configure.bufferline'))
  use(require('configure.colorizer'))
  use(require('configure.dashboard'))
  use(require('configure.git-blame'))
  use(require('configure.todo-comments'))

  -- yaclt
  use('~/git/yaclt.nvim')
end)
