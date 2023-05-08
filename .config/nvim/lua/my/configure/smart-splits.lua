return {
  'mrjones2014/smart-splits.nvim',
  dev = vim.fn.isdirectory(vim.fn.expand('~/git/smart-splits.nvim')) ~= 0,
  lazy = false,
  config = function()
    require('smart-splits').setup()
  end,
}
