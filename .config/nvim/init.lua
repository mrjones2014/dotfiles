-- impatient has to be loaded before anything else
local present, impatient = pcall(require, 'impatient')
if present then
  impatient.enable_profile()
end

require('my.globals')

-- force set colorscheme immediately
pcall(vim.cmd.colorscheme, 'onedarkpro')

require('my.disable-builtins')
require('my.settings')
require('my.plugins').setup()

if #vim.fn.argv() == 0 then
  require('my.startup').show()
end
