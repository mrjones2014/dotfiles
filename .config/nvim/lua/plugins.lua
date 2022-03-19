local paths = require('paths')

-- if packer isn't already installed, install it
local packer_bootstrap = false
if vim.fn.empty(vim.fn.glob(paths.plugin_install_path)) > 0 then
  packer_bootstrap = vim.fn.system({
    'git',
    'clone',
    'https://github.com/wbthomason/packer.nvim',
    paths.plugin_install_path,
  })
  vim.cmd('packadd packer.nvim')
end

local packer = require('packer')

packer.startup({
  function(use)
    -- impatient.nvim has to be loaded before anything else,
    -- it's also required in init.lua
    use('lewis6991/impatient.nvim')

    -- Packer can manage itself
    use('wbthomason/packer.nvim')

    -- Dependencies of other plugins
    use('nvim-lua/plenary.nvim')

    -- Plugins I develop
    use(require('configure.mine.legendary'))
    use(require('configure.mine.lighthaus'))
    use(require('configure.mine.smart-resize'))
    use(require('configure.mine.dash'))
    use(require('configure.mine.tldr'))

    -- Editing enhancements and tools
    use(require('configure.tmux-navigator'))
    use(require('configure.text-moving'))
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
    use(require('configure.luasnip'))
    use(require('configure.completion'))
    use(require('configure.vim-fish'))
    use(require('configure.trouble'))
    use(require('configure.treesitter'))
    use(require('configure.treesitter-playground'))

    -- UI + utils
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
    use(require('configure.startuptime'))
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
  require('packer').sync()
end
