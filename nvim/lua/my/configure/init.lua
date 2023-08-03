-- plugins with little or no config can go here

return {
  { 'nvim-lua/plenary.nvim' },
  { 'tpope/vim-eunuch', cmd = { 'Delete', 'Move', 'Chmod', 'SudoWrite', 'Rename' } },
  { 'tpope/vim-sleuth', event = 'BufReadPre' },
  { 'mrjones2014/iconpicker.nvim' },
  { 'mrjones2014/lua-gf.nvim', dev = true, ft = 'lua' },
  { 'echasnovski/mini.pairs', event = 'InsertEnter', opts = {} },
  { 'echasnovski/mini.trailspace', event = 'BufRead', opts = {} },
  { 'max397574/better-escape.nvim', event = 'InsertEnter', opts = {} },
  {
    'mrjones2014/glowy.nvim',
    dev = true,
    ft = 'markdown',
    dependencies = { 'norcalli/nvim-terminal.lua', config = true },
  },
  {
    'Wansmer/treesj',
    keys = {
      {
        'gS',
        function()
          require('treesj').toggle()
        end,
        desc = 'Toggle arrays/lists/etc. between single and multi line formats.',
      },
    },
    opts = {
      use_default_keymaps = false,
      max_join_length = 300,
    },
  },
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
