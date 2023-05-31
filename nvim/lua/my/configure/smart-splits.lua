return {
  'mrjones2014/smart-splits.nvim',
  dev = true,
  lazy = false,
  config = function()
    require('smart-splits').setup({ ignored_buftypes = { 'nofile' } })
  end,
}
