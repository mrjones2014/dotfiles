local path

local paths = require('paths')
if vim.fn.isdirectory(paths.join(paths.home, 'git/personal/tldr.nvim')) > 0 then
  path = '~/git/personal/tldr.nvim'
else
  path = 'mrjones2014/tldr.nvim'
end

return {
  path,
  cmd = 'Tldr',
  config = function()
    require('tldr').setup({ tldr_args = '--color always' })
  end,
}
