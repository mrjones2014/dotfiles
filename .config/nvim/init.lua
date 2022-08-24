-- impatient has to be loaded before anything else
local present, impatient = pcall(require, 'impatient')
if present then
  impatient.enable_profile()
end

require('my.disable-builtins')
require('my.settings')
require('my.plugins')
require('my.whitespace')
require('my.startup').show()
