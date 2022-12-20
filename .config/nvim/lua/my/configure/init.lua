return {
  { 'nvim-lua/plenary.nvim' },
  { 'tpope/vim-eunuch', cmd = { 'Delete', 'Move', 'Cmhod', 'SudoWrite' } },
  { 'tpope/vim-sleuth', lazy = false },
  {
    'folke/lazy.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    lazy = false,
  },
}
