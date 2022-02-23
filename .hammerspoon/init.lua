-- bind mouse side buttons to forward/back
hs.eventtap.new({ hs.eventtap.event.types.otherMouseUp }, function(event)
  local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
  if button == 3 then
    hs.eventtap.keyStroke({ 'cmd' }, '[')
  end
  if button == 4 then
    hs.eventtap.keyStroke({ 'cmd' }, ']')
  end
end):start()

-- bind shift+ctrl+option+command+s to sleep
hs.hotkey.bind({ 'cmd', 'alt', 'ctrl', 'shift' }, 'S', function()
  hs.caffeinate.systemSleep()
end)

-- bind shift+ctrl+option+l to lock screen
hs.hotkey.bind({ 'alt', 'ctrl', 'shift' }, 'L', function()
  hs.caffeinate.lockScreen()
end)

-- bind print screen key (F13 on mac) to screenshot tool
hs.hotkey.bind({}, 'f13', function()
  hs.eventtap.keyStroke({ 'cmd', 'shift' }, '5')
end)

local function handle_app_event(app_name, event_type, app_obj)
  -- no, Apple, I didn't mean to open Apple Music instead of Spotify
  if event_type == hs.application.watcher.launched and app_name == 'Music' then
    -- kill Apple Music
    app_obj:kill()
    -- open Spotify instead
    hs.application.open('Spotify')
  end

  -- no, Zoom, I don't want you to spy on my mic in the background
  if
    (event_type == hs.application.watcher.hidden or event_type == hs.application.watcher.terminated)
    and app_name == 'zoom.us'
  then
    -- make Zoom kill itself when I leave a meeting
    app_obj:kill()
  end
end

local app_watcher = hs.application.watcher.new(handle_app_event)
app_watcher:start()
