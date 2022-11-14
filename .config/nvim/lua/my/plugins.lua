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
  require('my.configure.mine.winbarbar'),

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
  require('my.configure.nvim-tree'),
  require('my.configure.indent-blankline'),
  require('my.configure.feline'),
  require('my.configure.colorizer'),
  require('my.configure.todo-comments'),
  require('my.configure.startuptime'),
  require('my.configure.noice'),
  require('my.configure.colorful-winsep'),
}

function M.setup()
  -- if packer isn't already installed, install it
  local packer_bootstrap = false
  if vim.fn.empty(vim.fn.glob(M.plugin_install_path)) > 0 then
    packer_bootstrap = not not vim.fn.system({
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
    max_jobs = 20,
  })
  packer.startup({
    function(use)
      local theme = require('my.configure.theme')
      for _, config in ipairs(M.plugin_configs) do
        if type(config) == 'table' then
          if config[1] == theme[1] then
            -- make the colorscheme load after impatient.nvim
            local after = config.after or {}
            after = type(after) == 'string' and { after } or after
            table.insert(after, 'impatient.nvim')
            config.after = after
          else
            -- make everything else load after the colorscheme
            local theme_module_name = theme[1]:sub(({ theme[1]:find('/') })[1] + 1)
            local after = config.after or {}
            after = type(after) == 'string' and { after } or after
            if not vim.tbl_contains(after, theme_module_name) then
              table.insert(after, theme_module_name)
              config.after = after
            end
          end

        end
          use(config)
      end
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
