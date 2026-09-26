---@return string
local function git_remote()
  local result = vim.system({ 'git', 'config', '--get', 'remote.origin.url' }, { text = true }):wait()
  if result.signal ~= 0 then
    return ''
  end
  return result.stdout or ''
end

---@return boolean
local function is_work_repo()
  local remote = git_remote()
  if not remote or remote == '' then
    return false
  end
  return remote:find('agilebits-inc', 1, true) ~= nil
end

---@type LazySpec
return {
  'saecki/crates.nvim',
  event = { 'BufRead Cargo.toml' },
  config = function(_, opts)
    -- at work we use `package.path = "..."` syntax in Cargo.toml
    -- a lot, and this breaks the parser
    if is_work_repo() then
      return
    end
    require('crates').setup(opts)
  end,
}
