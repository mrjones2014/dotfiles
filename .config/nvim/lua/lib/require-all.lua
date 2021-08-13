local M = {}

function M.requireAllRelative(path)
  local scan = require('plenary.scandir')
  for _, file in ipairs(scan.scan_dir(path, { depth = 0 })) do
    dofile(file)
  end
end

return M
