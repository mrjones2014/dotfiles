-- bind mouse side buttons to forward/back
hs.eventtap
  .new({ hs.eventtap.event.types.otherMouseUp }, function(event)
    local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
    if button == 3 then
      hs.eventtap.keyStroke({ 'cmd' }, '[')
    end
    if button == 4 then
      hs.eventtap.keyStroke({ 'cmd' }, ']')
    end
  end)
  :start()

-- bind shift+ctrl+option+l to lock screen
hs.hotkey.bind({ 'alt', 'ctrl', 'shift' }, 'L', function()
  hs.caffeinate.lockScreen()
end)

-- bind print screen key (F13 on mac) to screenshot tool
hs.hotkey.bind({}, 'f13', function()
  hs.eventtap.keyStroke({ 'cmd', 'shift' }, '5')
end)
