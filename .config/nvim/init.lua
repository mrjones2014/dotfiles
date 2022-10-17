-- impatient has to be loaded before anything else
local present, impatient = pcall(require, 'impatient')
if present then
  impatient.enable_profile()
end

require('my.disable-builtins')
require('my.globals')
require('my.settings')
require('my.plugins').setup()
require('my.whitespace')
if #vim.fn.argv() == 0 then
  require('my.startup').show()
end
