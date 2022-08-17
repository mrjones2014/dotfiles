local M = {}

function M.has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

--- Copy specified text to the clipboard.
---@param str string text to copy
function M.copy_to_clipboard(str)
  vim.fn.jobstart(string.format('echo %s | pbcopy', str), { detach = true })
end

--- Returns the git branch, if `cwd` is a git repository
---@return string
function M.git_branch()
  return vim.g.gitsigns_head
end

function M.open_url_under_cursor()
  vim.fn.jobstart({ 'open', vim.fn.expand('<cfile>') }, { detach = true })
end

return M
