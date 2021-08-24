local loadAll = require('modules.load-all')
local luaPath = os.getenv('HOME') .. '/.config/nvim/lua/'

require('modules.theme-manager').configureTheme('catppuccino')
loadAll(luaPath)
loadAll(luaPath .. 'plugins')
