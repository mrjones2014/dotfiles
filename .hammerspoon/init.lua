local function reload_config(files)
  local doReload = false
  for _, file in pairs(files) do
    if file:sub(-4) == '.lua' then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end

-- reload config every time it changes
local config_watcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', reload_config)
config_watcher:start()

require('keymaps')
require('zoom-killer')
require('apple-music-spotify-redirect')
