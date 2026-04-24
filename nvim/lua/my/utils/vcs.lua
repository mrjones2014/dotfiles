local _cached_remote

local M = {}

---@return string|nil
function M.git_remote()
  if _cached_remote == nil or _cached_remote == '' then
    local result = vim.system({ 'git', 'config', '--get', 'remote.origin.url' }, { text = true }):wait()
    if result.signal == 0 then
      _cached_remote = vim.trim(result.stdout)
    end
  end
  return _cached_remote or ''
end

---@return boolean
function M.is_work_repo()
  local remote = M.git_remote()
  if not remote or remote == '' then
    return false
  end
  return remote:find('gitlab.1password.io', 1, true) ~= nil or remote:find('agilebits-inc', 1, true) ~= nil
end

return M
