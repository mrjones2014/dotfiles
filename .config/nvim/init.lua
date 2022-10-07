-- impatient has to be loaded before anything else
local present, impatient = pcall(require, 'impatient')
if present then
  impatient.enable_profile()
end

-- utility for debugging lua stuff
_G.p = function(any)
  print(vim.inspect(any))
end

require('my.disable-builtins')
require('my.settings')
require('my.plugins').setup()
require('my.whitespace')
if #vim.fn.argv() == 0 then
  require('my.startup').show()
end
