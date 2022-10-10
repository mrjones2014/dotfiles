return {
  'gaoDean/autolist.nvim',
  ft = { 'markdown', 'text' },
  config = function()
    require('autolist').setup()
  end,
}
