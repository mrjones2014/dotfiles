local M = {}

M.compile_path = Path.join(vim.fn.stdpath('data'), 'site/pack/loader/start/packer.nvim/lua/packer_compiled.lua')

M.plugin_install_path = Path.join(vim.fn.stdpath('data'), 'site/pack/packer/start/packer.nvim')

M.plugin_configs = {
  -- impatient.nvim has to be loaded before anything else,
  -- it's also required in init.lua
  'lewis6991/impatient.nvim',

  -- Packer can manage itself
  'wbthomason/packer.nvim',

  -- Dependencies of other plugins
  'nvim-lua/plenary.nvim',
  require('my.configure.devicons'),

  -- Plugins I develop
  require('my.configure.mine.op'),
  require('my.configure.mine.legendary'),
  require('my.configure.mine.smart-splits'),

  -- Editing enhancements and tools
  require('my.configure.autopairs'),
  require('my.configure.comments'),
  require('my.configure.better-escape'),
  require('my.configure.leap'),
  require('my.configure.neotest'),
  require('my.configure.diffview'),
  'tpope/vim-eunuch',
  'tpope/vim-sleuth',

  -- LSP + syntax
  require('my.configure.lspconfig'),
  require('my.configure.completion'),
  require('my.configure.trouble'),
  require('my.configure.treesitter'),
  require('my.configure.treesitter-playground'),

  -- UI + utils
  require('my.configure.theme'),
  require('my.configure.dressing'),
  require('my.configure.autolist'),
  require('my.configure.markdown-preview'),
  require('my.configure.telescope'),
  require('my.configure.gitsigns'),
  require('my.configure.ide'),
  require('my.configure.indent-blankline'),
  require('my.configure.feline'),
  require('my.configure.colorizer'),
  require('my.configure.todo-comments'),
  require('my.configure.startuptime'),
  require('my.configure.noice'),
  require('my.configure.trailspace'),
  require('my.configure.octo'),
}

function M.setup()
  -- if packer isn't already installed, install it
  local packer_bootstrap = false
  if vim.fn.isdirectory(M.plugin_install_path) == 0 then
    packer_bootstrap = not not vim.fn.system({
      'git',
      'clone',
      'https://github.com/wbthomason/packer.nvim',
      M.plugin_install_path,
    })
    vim.cmd.packadd('packer.nvim')
  end

  local packer = require('packer')
  packer.startup({
    function(use)
      vim.tbl_map(function(plugin)
        if vim.tbl_islist(plugin) then
          vim.tbl_map(use, plugin)
        else
          use(plugin)
        end
      end, M.plugin_configs)
    end,
    config = {
      compile_path = M.compile_path,
      max_jobs = 20,
      profile = {
        enable = true,
        threshold = 0,
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
