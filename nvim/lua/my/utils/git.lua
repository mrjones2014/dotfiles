local _cached_remote

local M = {}

function M.git_remote()
  if _cached_remote == nil or _cached_remote == '' then
    local result = vim.system({ 'git', 'remote', 'get-url', 'origin' }, { text = true }):wait()
    if result.signal == 0 then
      _cached_remote = vim.trim(result.stdout)
    end
  end
  return _cached_remote or ''
end

function M.is_work_repo()
  return M.git_remote():find('1password.gitlab.io') ~= nil
end

return M
