-- use local theme repo if it's cloned
local paths = require('paths')
if vim.fn.isdirectory(paths.join(paths.home, 'git/personal/lighthaus.nvim')) > 0 then
  return {
    '~/git/personal/lighthaus.nvim',
    config = function()
      require('lighthaus').setup({ bg_dark = true })
    end,
  }
end

return {
  'mrjones2014/lighthaus.nvim',
  config = function()
    require('lighthaus').setup({ bg_dark = true })
  end,
}
