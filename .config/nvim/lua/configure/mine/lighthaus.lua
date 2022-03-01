-- use local theme repo if it's cloned
local paths = require('paths')
local plugin_path = 'mrjones2014/lighthaus.nvim'
if vim.fn.isdirectory(paths.join(paths.home, 'git/personal/lighthaus.nvim')) > 0 then
  plugin_path = '~/git/personal/lighthaus.nvim'
end

return {
  plugin_path,
  before = 'lualine.nvim',
  config = function()
    require('lighthaus').setup({
      bg_dark = true,
      italic_comments = true,
      italic_keywords = true,
    })
  end,
}
