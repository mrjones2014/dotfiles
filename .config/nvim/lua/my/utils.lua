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

--- Open the URL under the cursor, also handles plugin paths
--- such as mrjones2014/op.nvim and opens them on https://github.com
function M.open_url_under_cursor()
  local url = vim.fn.expand('<cfile>')
  -- plugin paths as interpreted by plugin manager, e.g. mrjones2014/op.nvim
  if not string.match(url, '[a-z]*://[^ >,;]*') and string.match(url, '[%w%p\\-]*/[%w%p\\-]*') then
    url = string.format('https://github.com/%s', url)
  end
  vim.fn.jobstart({ 'open', url }, { detach = true })
end

function M.join_lists(...)
  local lists = { ... }
  local result = {}
  for _, list in ipairs(lists) do
    vim.list_extend(result, list)
  end
  return result
end

return M
