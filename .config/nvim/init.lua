-- impatient has to be loaded before anything else
local present, impatient = pcall(require, 'impatient')
if present then
  impatient.enable_profile()
end

require('disable-builtins')
require('settings')
require('plugins')
require('whitespace')
require('startup')
