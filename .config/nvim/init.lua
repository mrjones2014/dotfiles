require('my.globals')
require('my.settings')
require('my.plugins')

if #vim.fn.argv() == 0 then
  require('my.startup').show()
end
