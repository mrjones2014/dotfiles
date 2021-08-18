local loadAll = require('load-all')
local luaPath = os.getenv('HOME') .. '/.config/nvim/lua/'

loadAll(luaPath)
loadAll(luaPath .. 'plugins')
require('modules.theme-manager').configureTheme('tokyonight')
