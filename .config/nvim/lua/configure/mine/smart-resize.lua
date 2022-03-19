local path

local paths = require('paths')
if vim.fn.isdirectory(paths.join(paths.home, 'git/personal/smart-resize.nvim')) > 0 then
  path = '~/git/personal/smart-resize.nvim'
else
  path = 'mrjones2014/smart-resize.nvim'
end

return { path }
