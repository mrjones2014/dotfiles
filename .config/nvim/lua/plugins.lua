-- if packer isn't already installed, install it
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({ 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path })
  vim.cmd('packadd packer.nvim')
end

require('packer').startup(function(use)
  -- Packer can manage itself
  use('wbthomason/packer.nvim')

  -- Dependencies of other plugins
  use('nvim-lua/plenary.nvim')

  -- Themes
  use(require('configure.theme'))

  -- Editing enhancements and tools
  use(require('configure.tmux-navigator'))
  use(require('configure.vim-move'))
  use(require('configure.telescope'))
  use(require('configure.autopairs'))
  use(require('configure.tagalong'))
  use(require('configure.markdown-preview'))
  use(require('configure.comments'))
  use(require('configure.better-escape'))

  -- Tim Pope plugins
  use(require('configure.vim-sleuth'))
  use(require('configure.vim-eunuch'))

  -- LSP + syntax
  use(require('configure.lspconfig'))
  use(require('configure.completion'))
  use(require('configure.vim-fish'))
  use(require('configure.trouble'))
  use(require('configure.treesitter'))
  use(require('configure.treesitter-playground'))

  -- UI + utils
  use(require('configure.greeter'))
  use(require('configure.gitsigns'))
  use(require('configure.icons'))
  use(require('configure.nvim-tree'))
  use(require('configure.indent-blankline'))
  use(require('configure.lualine'))
  use(require('configure.bufferline'))
  use(require('configure.colorizer'))
  use(require('configure.todo-comments'))
  use(require('configure.nvim-notify'))
  use(require('configure.dressing'))
  use(require('configure.fidget'))

  -- Plugins I develop (plus configure.theme [lighthaus.nvim])
  use(require('configure.mine.dash'))
  use(require('configure.mine.tldr'))
  use(require('configure.mine.legendary'))
end)

-- Automatically set up config if we just bootstrapped packer by git cloning it
if packer_bootstrap then
  require('packer').sync()
end
