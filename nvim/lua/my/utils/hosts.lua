local M = {}

function M.is_work_computer()
  return vim.fn.hostname() == 'corpo'
end

function M.is_server()
  return vim.fn.hostname() == 'mikoshi'
end

return M
