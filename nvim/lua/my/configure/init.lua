-- plugins with little or no config can go here

local function mini(plugin)
  local mod = vim.split(plugin[1], '/')[2]
  require(mod).setup({})
end

return {
  { 'nvim-lua/plenary.nvim' },
  { 'tpope/vim-eunuch', cmd = { 'Delete', 'Move', 'Chmod', 'SudoWrite', 'Rename' } },
  { 'tpope/vim-sleuth', lazy = false },
  { 'mrjones2014/iconpicker.nvim' },
  { 'mrjones2014/lua-gf.nvim', dev = true, ft = 'lua' },
  { 'echasnovski/mini.pairs', event = 'InsertEnter', config = mini },
  { 'echasnovski/mini.trailspace', event = 'BufRead', config = mini },
  {
    'echasnovski/mini.splitjoin',
    keys = {
      {
        'gS',
        desc = 'Toggle arrays/lists/etc. between single and multi line formats.',
      },
    },
    config = mini,
  },
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
