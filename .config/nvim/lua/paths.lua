local M = {}

function M.join(...)
  return table.concat({ ... }, '/')
end

M.home = os.getenv('HOME')

M.config = M.join(M.home, '.config')

return M
