local path

local paths = require('paths')
if vim.fn.isdirectory(paths.join(paths.home, 'git/personal/dash.nvim')) > 0 then
  path = '~/git/personal/dash.nvim'
else
  path = 'mrjones2014/dash.nvim'
end

return {
  path,
  -- requires = {
  --   'ibhagwan/fzf-lua',
  --   'vijaymarupudi/nvim-fzf',
  --   'camspiers/snap'
  -- }
}
