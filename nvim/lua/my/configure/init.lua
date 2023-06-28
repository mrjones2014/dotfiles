-- plugins with little or no config can go here

return {
  { 'nvim-lua/plenary.nvim' },
  { 'tpope/vim-eunuch', cmd = { 'Delete', 'Move', 'Chmod', 'SudoWrite', 'Rename' } },
  { 'tpope/vim-sleuth', lazy = false },
  { 'mrjones2014/iconpicker.nvim' },
  { 'mrjones2014/lua-gf.nvim', dev = true, ft = 'lua' },
  { 'echasnovski/mini.pairs', event = 'InsertEnter', opts = {} },
  { 'echasnovski/mini.trailspace', event = 'BufRead', opts = {} },
  { 'max397574/better-escape.nvim', event = 'InsertEnter', opts = {} },
  {
    'echasnovski/mini.splitjoin',
    keys = { { 'gS', desc = 'Toggle arrays/lists/etc. between single and multi line formats.' } },
    opts = {},
  },
  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    opts = {},
  },
  {
    'folke/lazy.nvim',
    lazy = false,
  },
}
