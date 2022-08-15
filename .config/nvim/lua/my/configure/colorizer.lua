local filetypes = {
  'css',
  'scss',
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'html',
}
return {
  'norcalli/nvim-colorizer.lua',
  ft = filetypes,
  cmd = 'ColorizerAttachToBuffer',
  config = function()
    require('colorizer').setup(filetypes)
  end,
}
