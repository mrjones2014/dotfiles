local path

local paths = require('paths')
if vim.fn.isdirectory(paths.join(paths.home, 'git/personal/smart-splits.nvim')) > 0 then
  path = '~/git/personal/smart-splits.nvim'
else
  path = 'mrjones2014/smart-splits.nvim'
end

return { path }
