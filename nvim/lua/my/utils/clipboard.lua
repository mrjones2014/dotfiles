local M = {}

-- use OSC52 yank so it works over SSH
local copy_fn = require('vim.ui.clipboard.osc52').copy('+')

---Copy string to system clipboard
---@param str string|string[]
function M.copy(str)
  if type(str) == 'string' then
    -- the built-in clipboard function
    -- takes a table of strings
    str = { str }
  end
  copy_fn(str)
end

return M
