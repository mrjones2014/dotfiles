-- plugins with little or no config can go here

return {
  { 'nvim-lua/plenary.nvim' },
  { 'tpope/vim-eunuch', cmd = { 'Delete', 'Move', 'Chmod', 'SudoWrite', 'Rename' } },
  { 'tpope/vim-sleuth', lazy = false },
  { 'tenxsoydev/karen-yank.nvim', config = true },
  { 'mrjones2014/iconpicker.nvim' },
  { 'mrjones2014/lua-gf.nvim', dev = true, ft = 'lua' },
  { 'echasnovski/mini.pairs', event = 'InsertEnter', opts = {}, config = true },
  { 'max397574/better-escape.nvim', event = 'InsertEnter', config = true },
  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    config = true,
  },
  {
    'folke/lazy.nvim',
    lazy = false,
  },
}
