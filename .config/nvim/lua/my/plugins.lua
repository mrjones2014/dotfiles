local M = {}

M.compile_path = Path.join(vim.fn.stdpath('data'), 'site/pack/loader/start/packer.nvim/lua/packer_compiled.lua')

M.plugin_install_path = Path.join(vim.fn.stdpath('data'), 'site/pack/packer/start/packer.nvim')

function M.setup()
  -- if packer isn't already installed, install it
  local packer_bootstrap = false
  if vim.fn.empty(vim.fn.glob(M.plugin_install_path)) > 0 then
    packer_bootstrap = vim.fn.system({
      'git',
      'clone',
      'https://github.com/wbthomason/packer.nvim',
      M.plugin_install_path,
    })
    vim.cmd.packadd('packer.nvim')
  end

  local packer = require('packer')
  packer.reset()
  packer.init({
    compile_path = M.compile_path,
  })
  packer.startup({
    function(use)
      -- impatient.nvim has to be loaded before anything else,
      -- it's also required in init.lua
      use('lewis6991/impatient.nvim')

      -- Packer can manage itself
      use('wbthomason/packer.nvim')

      -- Dependencies of other plugins
      use('nvim-lua/plenary.nvim')
      use('kyazdani42/nvim-web-devicons')

      -- Plugins I develop
      use(require('my.configure.mine.op'))
      use(require('my.configure.mine.legendary'))
      use(require('my.configure.mine.smart-splits'))
      use(require('my.configure.mine.winbarbar'))

      -- Editing enhancements and tools
      use(require('my.configure.autopairs'))
      use(require('my.configure.comments'))
      use(require('my.configure.better-escape'))
      use(require('my.configure.leap'))
      use(require('my.configure.neotest'))
      use(require('my.configure.diffview'))
      use('tpope/vim-eunuch')
      use('tpope/vim-sleuth')

      -- LSP + syntax
      use(require('my.configure.lspconfig'))
      use(require('my.configure.completion'))
      use(require('my.configure.trouble'))
      use(require('my.configure.treesitter'))
      use(require('my.configure.treesitter-playground'))

      -- UI + utils
      use(require('my.configure.theme'))
      use(require('my.configure.dressing'))
      use(require('my.configure.autolist'))
      use(require('my.configure.markdown-preview'))
      use(require('my.configure.telescope'))
      use(require('my.configure.gitsigns'))
      use(require('my.configure.nvim-tree'))
      use(require('my.configure.indent-blankline'))
      use(require('my.configure.feline'))
      use(require('my.configure.colorizer'))
      use(require('my.configure.todo-comments'))
      use(require('my.configure.startuptime'))
      use(require('my.configure.noice'))
    end,
    config = {
      profile = {
        enable = true,
        threshold = 1,
      },
      display = {
        open_fn = function()
          return require('packer.util').float({ border = 'single' })
        end,
      },
    },
  })

  -- Automatically set up config if we just bootstrapped packer by git cloning it
  if packer_bootstrap then
    packer.sync()
  end

  pcall(require, 'packer_compiled')
end

return M
