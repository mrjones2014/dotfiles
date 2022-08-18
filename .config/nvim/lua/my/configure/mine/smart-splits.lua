local path

local paths = require('my.paths')
if vim.fn.isdirectory(paths.join(paths.home, 'git/github/smart-splits.nvim')) > 0 then
  path = '~/git/github/smart-splits.nvim'
else
  path = 'mrjones2014/smart-splits.nvim'
end

return { path }
