local filetypes = vim.list_extend(vim.deepcopy(require('my.lsp.filetypes').filetypes), { 'conf', 'tmux', 'Onedarkpro' })
return {
  'norcalli/nvim-colorizer.lua',
  ft = filetypes,
  cmd = 'ColorizerAttachToBuffer',
  config = function()
    require('colorizer').setup(filetypes)
  end,
}
