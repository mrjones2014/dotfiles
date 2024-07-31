-- plugins with little or no config can go here

return {
  { 'nvim-lua/plenary.nvim' },
  {
    'DaikyXendo/nvim-material-icon',
    main = 'nvim-web-devicons',
    opts = {},
  },
  { 'tpope/vim-eunuch', cmd = { 'Delete', 'Move', 'Chmod', 'SudoWrite', 'Rename' } },
  { 'tpope/vim-sleuth', event = 'BufReadPre' },
  {
    'nat-418/boole.nvim',
    keys = { '<C-a>', '<C-x>' },
    opts = { mappings = { increment = '<C-a>', decrement = '<C-x>' } },
  },
  { 'mrjones2014/iconpicker.nvim' },
  { 'mrjones2014/lua-gf.nvim', dev = true, ft = 'lua' },
  {
    'echasnovski/mini.splitjoin',
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
  { 'echasnovski/mini.trailspace', event = 'BufRead', opts = {} },
  { 'max397574/better-escape.nvim', event = 'InsertEnter', opts = {} },
  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    opts = {},
  },
  {
    'folke/lazy.nvim',
    lazy = false,
    keys = {
      {
        '<leader>L',
        function()
          vim.cmd.Lazy()
        end,
      },
    },
  },
}
