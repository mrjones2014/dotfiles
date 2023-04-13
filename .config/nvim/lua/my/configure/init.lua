return {
  { 'nvim-lua/plenary.nvim' },
  { 'tpope/vim-eunuch', cmd = { 'Delete', 'Move', 'Chmod', 'SudoWrite', 'Rename' } },
  { 'tpope/vim-sleuth', lazy = false },
  { 'tenxsoydev/karen-yank.nvim', config = true },
  { 'mrjones2014/iconpicker.nvim' },
  { 'mrjones2014/lua-gf.nvim', dev = true, ft = 'lua' },
  {
    'folke/lazy.nvim',
    lazy = false,
  },
}
