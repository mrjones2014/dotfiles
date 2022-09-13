local paths = require('my.paths')

-- if packer isn't already installed, install it
local packer_bootstrap = false
if vim.fn.empty(vim.fn.glob(paths.plugin_install_path)) > 0 then
  packer_bootstrap = vim.fn.system({
    'git',
    'clone',
    'https://github.com/wbthomason/packer.nvim',
    paths.plugin_install_path,
  })
  vim.cmd.packadd('packer.nvim')
end

local packer = require('packer')
packer.init({
  compile_path = paths.join(vim.fn.stdpath('data'), 'site/pack/loader/start/packer.nvim/lua/packer_compiled.lua'),
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
    use(require('my.configure.mine.dash'))

    -- Editing enhancements and tools
    use(require('my.configure.autopairs'))
    use(require('my.configure.comments'))
    use(require('my.configure.better-escape'))
    use(require('my.configure.lightspeed'))
    use(require('my.configure.neotest'))
    use('tpope/vim-eunuch')
    use('tpope/vim-sleuth')
    use('tpope/vim-fugitive')

    -- LSP + syntax
    use(require('my.configure.mason'))
    use(require('my.configure.lspconfig'))
    use(require('my.configure.luasnip'))
    use(require('my.configure.completion'))
    use(require('my.configure.trouble'))
    use(require('my.configure.goto-preview'))
    use(require('my.configure.treesitter'))
    use(require('my.configure.treesitter-playground'))

    -- UI + utils
    use(require('my.configure.theme'))
    use(require('my.configure.markdown-preview'))
    use(require('my.configure.telescope'))
    use(require('my.configure.gitsigns'))
    use(require('my.configure.nvim-tree'))
    use(require('my.configure.indent-blankline'))
    use(require('my.configure.feline'))
    use(require('my.configure.colorizer'))
    use(require('my.configure.todo-comments'))
    use(require('my.configure.nvim-notify'))
    use(require('my.configure.dressing'))
    use(require('my.configure.startuptime'))
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
