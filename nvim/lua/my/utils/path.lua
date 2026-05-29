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

---Get just the filename from a path
---@param path string
---@return string
function M.filename(path)
  return vim.fn.fnamemodify(path, ':t')
end

---@param bufnr integer
function M.is_tempfile(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return vim.startswith(name, '/tmp')
    or vim.startswith(name, '/private/tmp')
    or vim.startswith(name, '/var/folders/')
    or vim.startswith(name, '/private/var/folders/')
end

return M
