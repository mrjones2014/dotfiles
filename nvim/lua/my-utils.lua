local M = {}

local _cached_git_remote
---@return string
function M.git_remote()
  if _cached_git_remote then
    return _cached_git_remote
  end
  local result = vim.system({ 'git', 'config', '--get', 'remote.origin.url' }, { text = true }):wait()
  if result.signal ~= 0 or result.stdout == '' then
    return ''
  end
  _cached_git_remote = vim.trim(result.stdout)
  return _cached_git_remote
end

---@return boolean
function M.is_work_repo()
  local remote = M.git_remote()
  if not remote or remote == '' then
    return false
  end
  return remote:find('agilebits-inc', 1, true) ~= nil
end

return M
