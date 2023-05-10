-- no, Zoom, I don't want you to spy on my mic in the background
local function kill_zoom(app_name, event_type, app)
  if
    (
      event_type == hs.application.watcher.hidden
      or event_type == hs.application.watcher.terminated
      or event_type == hs.application.watcher.deactivated
    ) and app_name == 'zoom.us'
  then
    -- make Zoom kill itself when I leave a meeting
    local all_windows = app:allWindows()
    -- if there are zero windows, then kill it
    if #all_windows == 0 then
      app:kill()
    elseif #all_windows == 1 then
      -- if the only window is the main non-meeting window, then kill it
      if all_windows[1]:title() == 'Zoom' then
        app:kill()
      end
    end
  end
end

zoom_killer = hs.application.watcher.new(kill_zoom)
zoom_killer:start()
