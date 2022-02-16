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
  local cwd_pattern = (vim.fn.getcwd() .. '/'):gsub('[%(%)%.%%%+%-%*%?%[%]%^%$]', function(c)
    return '%' .. c
  end)
  path = path:gsub(cwd_pattern, '')
  -- replace $HOME with ~
  local home_pattern = (os.getenv('HOME') .. '/'):gsub('[%(%)%.%%%+%-%*%?%[%]%^%$]', function(c)
    return '%' .. c
  end)
  if replace_home_with_tilde then
    path = path:gsub(home_pattern, '~/')
  else
    path = path:gsub(home_pattern, '')
  end
  if vim.fn.winwidth(0) <= 84 then
    path = vim.fn.pathshorten(path)
  end

  if not path or #path == 0 then
    return ''
  end

  return path
end

return M
