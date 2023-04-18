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

local function wake_callback()
  hs.timer.doAfter(1, hs.reload)
end

-- reload config every time it changes
config_watcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.config/hammerspoon/', reload_config)
config_watcher:start()

-- reload config when waking from sleep
sleep_watcher = hs.caffeinate.watcher.new(wake_callback)
sleep_watcher:start()

require('keymaps')
require('zoom-killer')
require('apple-music-spotify-redirect')
