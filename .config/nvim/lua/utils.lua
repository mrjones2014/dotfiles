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

function M.split_to_lines(str)
  local lines = {}

  for s in str:gmatch('[^\r\n]+') do
    table.insert(lines, s)
  end

  return lines
end

function M.trim_str(str)
  return (string.gsub(str, '^%s*(.-)%s*$', '%1'))
end

function M.open_url_under_cursor()
  if vim.fn.has('mac') == 1 then
    vim.cmd('call jobstart(["open", expand("<cfile>")], {"detach": v:true})')
  elseif vim.fn.has('unix') == 1 then
    vim.cmd('call jobstart(["xdg-open", expand("<cfile>")], {"detach": v:true})')
  else
    vim.notify('Error: gx is not supported on this OS!')
  end
end

return M
