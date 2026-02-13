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

local _cached_branch = ''
local _cache_valid = false

---@return string|nil
function M.jj_bookmark_or_git_branch()
  if not _cache_valid then
    if vim.fs.root(assert(vim.uv.cwd()), '.jj') then
      local result = vim
        .system({
          'jj',
          'log',
          '--ignore-working-copy',
          '-r',
          '@-',
          '-n',
          '1',
          '--no-graph',
          '--no-pager',
          '-T',
          "separate(' ', format_short_change_id(self.change_id()), self.bookmarks())",
        }, { text = true })
        :wait()
      _cached_branch = vim.trim(result.stdout or '')
    else
      _cached_branch = vim.g.gitsigns_head
        or vim.b.gitsigns_head
        or vim.trim(vim.system({ 'git', 'branch', '--show-current' }, { text = true }):wait().stdout or '')
    end
    _cache_valid = true
  end

  return _cached_branch
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'GitSignsUpdate',
  callback = function()
    _cache_valid = false
    vim.schedule(vim.cmd.redrawstatus)
  end,
})

return M
