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

function M.relative_cwd()
  return M.relative_filepath(vim.loop.cwd(), true)
end

function M.relative_filepath(path, replace_home_with_tilde)
  path = path or vim.fn.expand('%')
  -- ensure path is relative to cwd
  path = path:gsub(M.pattern_to_literal(vim.loop.cwd()), '')
  -- replace $HOME with ~
  if replace_home_with_tilde then
    path = path:gsub(M.pattern_to_literal(require('paths').home), '~/')
  else
    path = path:gsub(M.pattern_to_literal(require('paths').home), '')
  end
  if vim.fn.winwidth(0) <= 84 then
    path = vim.fn.pathshorten(path)
  end

  if not path or #path == 0 then
    return ''
  end

  return path
end

function M.pattern_to_literal(pat)
  return pat:gsub('[%(%)%.%%%+%-%*%?%[%]%^%$]', function(c)
    return '%' .. c
  end)
end

return M
