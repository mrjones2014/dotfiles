local M = {}

function M.join(...)
  return table.concat({ ... }, '/')
end

function M.relative_cwd()
  local path = vim.loop.cwd()
  path = path:gsub(vim.pesc(require('paths').home), '~/'):gsub('//', '/')
  return path
end

function M.relative_filepath(path, replace_home_with_tilde)
  if replace_home_with_tilde == nil then
    replace_home_with_tilde = true
  end
  path = path or vim.fn.expand('%')
  -- ensure path is relative to cwd
  local new_path = path:gsub(vim.pesc(vim.loop.cwd()), '')
  -- if filepath is relative to cwd, ensure it doesn't have a leading /
  if #path ~= #new_path then
    if new_path:sub(1, 1) == '/' then
      new_path = new_path:sub(2)
    end

    path = new_path
  end

  -- replace $HOME with ~
  if replace_home_with_tilde then
    path = path:gsub(vim.pesc(require('paths').home), '~/'):gsub('//', '/')
  else
    path = path:gsub(vim.pesc(require('paths').home), '')
  end
  if (vim.o.laststatus < 3 and vim.fn.winwidth(0) <= 84) or (vim.o.laststatus == 3 and vim.o.columns <= 84) then
    path = vim.fn.pathshorten(path)
  end

  if not path or #path == 0 then
    return ''
  end

  return path
end

M.home = vim.env.HOME

M.config = M.join(M.home, '.config')

M.plugin_install_path = M.join(vim.fn.stdpath('data'), 'site/pack/packer/start/packer.nvim')

return M
