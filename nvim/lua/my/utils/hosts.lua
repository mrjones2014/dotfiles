local M = {}

function M.is_work_computer()
  return vim.fn.hostname() == 'corpo'
end

return M
