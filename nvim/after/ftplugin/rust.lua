local mp = require('mini.pairs')

mp.map_buf(0, 'i', '<', { action = 'open', pair = '<>', neigh_pattern = '[%a:].', register = { cr = false } })
mp.map_buf(0, 'i', '>', { action = 'close', pair = '<>', register = { cr = false } })

-- Don't close single quote if we're in a lifetime position.
mp.map_buf(0, 'i', "'", { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\<&].', register = { cr = false } })
