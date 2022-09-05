-- use local theme repo if it's cloned
local paths = require('my.paths')
local plugin_path = 'mrjones2014/op.nvim'
if vim.fn.isdirectory(paths.join(paths.home, 'git/github/op.nvim')) > 0 then
  plugin_path = '~/git/github/op.nvim'
end

return {
  plugin_path,
  run = 'make install',
  config = function()
    require('op').setup({
      statusline_fmt = function(account)
        if not account or #account == 0 then
          return ' 1P: Signed Out'
        end

        return string.format(' 1P: %s', account)
      end,
    })
  end,
}
