local M = {}

---Copy string to system clipboard
---@param str string
function M.copy(str)
  if vim.loop.os_uname().sysname == 'Darwin' then
    vim.fn.jobstart(string.format('echo -n %q | pbcopy', str), { detach = true })
  else
    vim.fn.jobstart(string.format('echo -n %q | xclip -sel clip', str), { detach = true })
  end
end

return M
