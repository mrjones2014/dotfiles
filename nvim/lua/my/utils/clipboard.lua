local M = {}

-- use OSC52 yank so it works over SSH
local copy_fn = require('vim.ui.clipboard.osc52').copy('+')

---Copy string to system clipboard
---@param str string
function M.copy(str)
  copy_fn(str)
end

return M
