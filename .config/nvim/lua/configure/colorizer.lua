return {
  'norcalli/nvim-colorizer.lua',
  event = 'BufLeave', -- when leaving dashboard buffer
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
