local M = {}

function M.has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

function M.copy_to_clipboard(str)
  vim.cmd(string.format('call jobstart("echo %s | pbcopy")', str))
end

function M.git_branch()
  return vim.g.gitsigns_head
end

function M.pattern_to_literal(pat)
  return pat:gsub('[%(%)%.%%%+%-%*%?%[%]%^%$]', function(c)
    return '%' .. c
  end)
end

return M
