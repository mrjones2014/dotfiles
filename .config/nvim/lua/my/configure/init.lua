-- plugins with little or no config can go here

local function mini(plugin)
  local mod = vim.split(plugin[1], '/')[2]
  require(mod).setup({})
end

return {
  { 'nvim-lua/plenary.nvim' },
  { 'tpope/vim-eunuch', cmd = { 'Delete', 'Move', 'Chmod', 'SudoWrite', 'Rename' } },
  { 'tpope/vim-sleuth', lazy = false },
  { 'tenxsoydev/karen-yank.nvim', config = true, lazy = false },
  { 'mrjones2014/iconpicker.nvim' },
  { 'mrjones2014/lua-gf.nvim', dev = vim.fn.isdirectory(vim.fn.expand('~/git/lua-gf')) ~= 0, ft = 'lua' },
  { 'echasnovski/mini.pairs', event = 'InsertEnter', config = mini },
  { 'echasnovski/mini.trailspace', event = 'BufRead', config = mini },
  { 'echasnovski/mini.splitjoin', keys = { 'gS' }, config = mini },
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
