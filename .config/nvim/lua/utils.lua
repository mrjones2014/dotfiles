local M = {}

function M.copy_to_clipboard(str)
  vim.cmd(string.format('call jobstart("echo %s | pbcopy")', str))
end

function M.git_branch()
  return vim.g.gitsigns_head
end

function M.relative_filepath()
  local path = vim.fn.expand('%')
  -- ensure path is relative to cwd
  local cwd_pattern = (vim.fn.getcwd() .. '/'):gsub('[%(%)%.%%%+%-%*%?%[%]%^%$]', function(c)
    return '%' .. c
  end)
  path = path:gsub(cwd_pattern, '')
  -- replace $HOME with ~
  local home_pattern = (os.getenv('HOME') .. '/'):gsub('[%(%)%.%%%+%-%*%?%[%]%^%$]', function(c)
    return '%' .. c
  end)
  path = path:gsub(home_pattern, '')
  if vim.fn.winwidth(0) <= 84 then
    path = vim.fn.pathshorten(path)
  end

  if not path or #path == 0 then
    return ''
  end

  return path
end

return M
