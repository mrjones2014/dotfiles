-- plugins with little or no config can go here

return {
  { 'nvim-lua/plenary.nvim' },
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
    'echasnovski/mini.pairs',
    event = 'InsertEnter',
    opts = {
      mappings = {
        -- source: https://old.reddit.com/r/neovim/comments/163rzex/how_to_avoid_autocompleting_right_parentheses/jy4zwp8/
        -- disable if a matching character is in an adjacent position (eg. fixes
        -- markdown triple ticks) neigh_pattern: a pattern for *two* neighboring
        -- characters (before and after). Use dot `.` to allow any character.
        -- Here, we disable the functionality instead of inserting a matching quote
        -- if there is an adjacent non-space character
        ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^%S][^%S]', register = { cr = false } },
      },
    },
  },
  { 'echasnovski/mini.trailspace', event = 'BufRead', opts = {} },
  { 'max397574/better-escape.nvim', event = 'InsertEnter', opts = {} },
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
