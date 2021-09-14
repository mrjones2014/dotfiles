-- if packer isn't already installed, install it
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path })
  vim.cmd('packadd packer.nvim')
end

return require('packer').startup(function(use)
  -- Packer can manage itself
  use('wbthomason/packer.nvim')

  -- Dependencies of other plugins
  use('nvim-lua/plenary.nvim')
  use('nvim-lua/popup.nvim')

  -- Themes
  use(require('configure.catppuccino'))

  -- Editing enhancements and tools
  use(require('configure.vim-tmux-navigator'))
  use(require('configure.vim-move'))
  use(require('configure.telescope'))
  use(require('configure.telescope-fzf-native'))
  use(require('configure.autopairs'))
  use(require('configure.tagalong'))
  use(require('configure.fterm'))
  use(require('configure.markdown-preview'))
  use(require('configure.kommentary'))

  -- Tim Pope plugins
  use(require('configure.vim-sleuth'))
  use(require('configure.vim-eunuch'))

  -- LSP + syntax
  use(require('configure.lspconfig'))
  use(require('configure.emmet'))
  use(require('configure.vim-go')) -- just used for gohtmltmpl syntax highlighting
  use(require('configure.completion'))
  use(require('configure.lspkind'))
  use(require('configure.vim-fish'))
  use(require('configure.trouble'))
  use(require('configure.treesitter'))
  use(require('configure.treesitter-playground'))

  -- UI + utils
  use(require('configure.gitgutter'))
  use(require('configure.nonicons'))
  use(require('configure.nvim-tree'))
  use(require('configure.indent-blankline'))
  use(require('configure.lualine'))
  use(require('configure.bufferline'))
  use(require('configure.colorizer'))
  use(require('configure.dashboard'))
  use(require('configure.git-blame'))
  use(require('configure.todo-comments'))

  if vim.fn.isdirectory('~/git/personal/yaclt.nvim') then
    -- yaclt
    use('~/git/personal/yaclt.nvim')
  end
end)
