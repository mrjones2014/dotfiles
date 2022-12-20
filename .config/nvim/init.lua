-- impatient has to be loaded before anything else
-- pcall(require, 'impatient')

require('my.globals')

-- force set colorscheme immediately
-- pcall(require('my.configure.theme').config)

require('my.settings')

require('my.plugins')

if #vim.fn.argv() == 0 then
  require('my.startup').show()
end
