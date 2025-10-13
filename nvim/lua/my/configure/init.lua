-- plugins with little or no config can go here

return {
  { 'nvim-lua/plenary.nvim' },
  {
    'DaikyXendo/nvim-material-icon',
    opts = {},
  },
  { 'tpope/vim-eunuch', cmd = { 'Delete', 'Move', 'Chmod', 'SudoWrite', 'Rename' } },
  { 'tpope/vim-sleuth', event = 'BufReadPre' },
  {
    'nat-418/boole.nvim',
    keys = { '<C-a>', '<C-x>' },
    opts = { mappings = { increment = '<C-a>', decrement = '<C-x>' } },
  },
  { 'mrjones2014/lua-gf.nvim', dev = true, ft = 'lua' },
  {
    'nvim-mini/mini.splitjoin',
    keys = {
      {
        'gS',
        function()
          require('mini.splitjoin').toggle()
        end,
        desc = 'Split/join arrays, argument lists, etc. from one vs. multiline and vice versa',
      },
    },
  },
  { 'nvim-mini/mini.trailspace', event = 'BufRead', opts = {} },
  {
    'max397574/better-escape.nvim',
    event = 'InsertEnter',
    opts = {
      mappings = {
        -- do not map jj because I use jujutsu and the command is jj
        i = { j = { k = '<Esc>', j = false } },
        c = { j = { k = '<Esc>', j = false } },
      },
    },
  },
  {
    'saecki/crates.nvim',
    -- work project has big Cargo.toml files with lots of dependencies
    -- that use `thing.path = "../../etc"` which breaks crates.nvim
    -- and makes the buffer become unresponsive
    enabled = not require('my.utils.vcs').is_work_repo(),
    event = { 'BufRead Cargo.toml' },
    opts = {},
  },
  {
    'tiagovla/scope.nvim',
    opts = {},
    event = 'TabNewEntered',
    keys = {
      {
        '<PageUp>',
        function()
          if #vim.api.nvim_list_tabpages() > 1 then
            vim.cmd.tabNext()
          else
            vim.cmd.tabnew()
          end
        end,
        desc = 'Next tab',
      },
      {
        '<PageDown>',
        function()
          if #vim.api.nvim_list_tabpages() > 1 then
            vim.cmd.tabPrevious()
          else
            vim.cmd.tabnew()
          end
        end,
        desc = 'Previous tab',
      },
    },
  },
  {
    'folke/lazy.nvim',
    lazy = false,
  },
}
