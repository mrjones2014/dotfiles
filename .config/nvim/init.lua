local requireAll = require('lib.require-all').requireAllRelative
local luaPath = os.getenv('HOME') .. '/.config/nvim/lua/'

requireAll(luaPath)
requireAll(luaPath .. 'plugins')
