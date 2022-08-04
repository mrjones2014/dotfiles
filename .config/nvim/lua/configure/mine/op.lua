-- use local theme repo if it's cloned
local paths = require('paths')
local plugin_path = 'mrjones2014/op.nvim'
if vim.fn.isdirectory(paths.join(paths.home, 'git/personal/op.nvim')) > 0 then
  plugin_path = '~/git/personal/op.nvim'
end

return {
  plugin_path,
  run = 'make install',
}
