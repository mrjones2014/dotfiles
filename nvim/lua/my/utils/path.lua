local M = {}

---Join two or more paths together
---@param ... string
---@return string
function M.join(...)
  return vim.fn.simplify(table.concat({ ... }, '/'))
end

---Get path relative to current working directory,
---replacing `$HOME` with `~` if applicable.
---@param path string
---@return string
function M.relative(path)
  return vim.fn.fnamemodify(path, ':~:.') or path
end

return M
