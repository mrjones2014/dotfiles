-- impatient has to be loaded before anything else
pcall(require, 'impatient')

require('my.globals')

-- force set colorscheme immediately
pcall(require('my.configure.theme').config)

require('my.disable-builtins')
require('my.settings')
require('my.plugins').setup()

if #vim.fn.argv() == 0 then
  require('my.startup').show()
end
