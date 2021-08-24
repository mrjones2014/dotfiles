return {
  'norcalli/nvim-colorizer.lua',
  event = 'BufEnter',
  config = function()
    require('colorizer').setup({
      'css',
      'scss',
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'html',
    })
  end,
}
