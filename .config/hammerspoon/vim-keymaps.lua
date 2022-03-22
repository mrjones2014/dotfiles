local VimMode = hs.loadSpoon('VimMode')
local vim = VimMode:new()

vim:disableForApp('Code'):disableForApp('zoom.us'):disableForApp('kitty'):enterWithSequence('jk')
vim:enableBetaFeature('block_cursor_overlay')
