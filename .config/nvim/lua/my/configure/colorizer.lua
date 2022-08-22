local filetypes = require('my.lsp.filetypes').filetypes
return {
  'norcalli/nvim-colorizer.lua',
  ft = filetypes,
  cmd = 'ColorizerAttachToBuffer',
  config = function()
    require('colorizer').setup(filetypes)
  end,
}
