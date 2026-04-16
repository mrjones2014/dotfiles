local uv = vim.uv

---@class MiniFilesGitignoreContentOpts
---@field sort fun(fs_entries: table): table
---@field filter fun(fs_entry: table): boolean

---@class MiniFilesGitignore
---@field config { max_cache_size: integer, max_concurrent_jobs: integer, cache_ttl: integer, sync_threshold: integer, prefetch_depth: integer }
---@field cache table<string, { ignored: table<string, boolean>, timestamp: number, gitignore_files: table<string, integer>, expires_at: number }>
---@field state boolean
---@field initial_sort fun(fs_entries: table): table
---@field initial_filter fun(fs_entry: table): boolean
---@field current_sort fun(fs_entries: table): table
---@field current_filter fun(fs_entry: table): boolean
---@field git_roots table<string, string?>
---@field fs_watchers table<string, uv.uv_fs_event_t>
---@field job_pool table<integer, { dir: string }>
---@field active_jobs_count integer
local MiniFilesGitignore = {}

local DEFAULT_CONFIG = {
  max_cache_size = 200,
  max_concurrent_jobs = 10,
  cache_ttl = 300,
  sync_threshold = 50,
  prefetch_depth = 1,
}

---@param opts { content: MiniFilesGitignoreContentOpts }
---@param config? { max_cache_size?: integer, max_concurrent_jobs?: integer, cache_ttl?: integer, sync_threshold?: integer, prefetch_depth?: integer }
---@return MiniFilesGitignore
function MiniFilesGitignore.new(opts, config)
  local self = setmetatable({}, { __index = MiniFilesGitignore })

  self.config = vim.tbl_deep_extend('force', DEFAULT_CONFIG, config or {})

  -- state=false means filter is active (hiding ignored files)
  -- state=true means unfiltered (showing all)
  self.cache = {}
  self.state = false
  self.initial_sort = opts.content.sort
  self.initial_filter = opts.content.filter
  self.current_sort = self.initial_sort
  self.current_filter = self.initial_filter
  self.git_roots = {}
  self.fs_watchers = {}
  self.job_pool = {}
  self.active_jobs_count = 0

  return self
end

---@return fun(fs_entries: table): table
function MiniFilesGitignore:get_sort()
  return self.current_sort
end

---@return fun(fs_entry: table): boolean
function MiniFilesGitignore:get_filter()
  return self.current_filter
end

---@param dir string
---@return string?
function MiniFilesGitignore:find_git_root(dir)
  if self.git_roots[dir] then
    return self.git_roots[dir]
  end

  local current = dir
  while current and #current > 1 do
    local git_dir = current .. '/.git'
    local stat = uv.fs_stat(git_dir)
    if stat then
      self.git_roots[dir] = current
      return current
    end
    current = vim.fn.fnamemodify(current, ':h')
  end

  self.git_roots[dir] = nil
  return nil
end

---@param dir string
---@return string[]
function MiniFilesGitignore:get_gitignore_files(dir)
  local git_root = self:find_git_root(dir)
  if not git_root then
    return {}
  end

  local gitignore_files = {}
  local current = dir

  while current and #current >= #git_root do
    local gitignore_path = current .. '/.gitignore'
    if uv.fs_stat(gitignore_path) then
      table.insert(gitignore_files, gitignore_path)
    end
    if current == git_root then
      break
    end
    current = vim.fn.fnamemodify(current, ':h')
  end

  return gitignore_files
end

---@param dir string
---@return boolean
function MiniFilesGitignore:is_cache_valid(dir)
  local cache_entry = self.cache[dir]
  if not cache_entry then
    return false
  end

  if cache_entry.expires_at < uv.hrtime() / 1e9 then
    return false
  end

  for file_path, cached_mtime in pairs(cache_entry.gitignore_files) do
    local stat = uv.fs_stat(file_path)
    local current_mtime = stat and stat.mtime.sec or 0
    if current_mtime ~= cached_mtime then
      return false
    end
  end

  return true
end

---@private
function MiniFilesGitignore:cleanup_cache()
  local current_time = uv.hrtime() / 1e9
  local cache_count = 0

  for dir, cache_entry in pairs(self.cache) do
    if cache_entry.expires_at < current_time then
      self.cache[dir] = nil
    else
      cache_count = cache_count + 1
    end
  end

  if cache_count > self.config.max_cache_size then
    local entries = {}
    for dir, cache_entry in pairs(self.cache) do
      table.insert(entries, { dir = dir, timestamp = cache_entry.timestamp })
    end

    table.sort(entries, function(a, b)
      return a.timestamp < b.timestamp
    end)

    local to_remove = math.max(1, math.floor(self.config.max_cache_size * 0.2))
    to_remove = math.min(to_remove, #entries)

    for i = 1, to_remove do
      self.cache[entries[i].dir] = nil
    end
  end
end

---@param dir string
---@param file_path string
---@return boolean
function MiniFilesGitignore:is_file_ignored(dir, file_path)
  if not self:is_cache_valid(dir) then
    return false
  end
  return self.cache[dir].ignored[file_path] or false
end

---@param dir string
---@param file_paths string[]
---@return table<string, boolean>
function MiniFilesGitignore:process_files_sync(dir, file_paths)
  local git_root = self:find_git_root(dir)
  if not git_root then
    return {}
  end

  local temp_file = vim.fn.tempname()
  local file_handle = io.open(temp_file, 'w')
  if not file_handle then
    return {}
  end

  for _, file_path in ipairs(file_paths) do
    file_handle:write(file_path .. '\n')
  end
  file_handle:close()

  local cmd =
    string.format('cd %s && git check-ignore --stdin < %s', vim.fn.shellescape(git_root), vim.fn.shellescape(temp_file))

  local result = vim.fn.system(cmd)
  vim.fn.delete(temp_file)

  local ignored_map = {}
  if vim.v.shell_error == 0 or vim.v.shell_error == 1 then
    for ignored_file in result:gmatch('[^\n]+') do
      ignored_map[ignored_file] = true
    end
  end

  return ignored_map
end

---@param dir string
---@param file_paths string[]
---@param callback fun(ignored_map: table<string, boolean>)
---@param is_prefetch boolean
function MiniFilesGitignore:process_files_async(dir, file_paths, callback, is_prefetch)
  if is_prefetch and self.active_jobs_count >= self.config.max_concurrent_jobs then
    return
  end

  if self.active_jobs_count >= (self.config.max_concurrent_jobs * 2) then
    callback({})
    return
  end

  local git_root = self:find_git_root(dir)
  if not git_root then
    callback({})
    return
  end

  self.active_jobs_count = self.active_jobs_count + 1

  local ignored_files = {}
  local job_id = vim.fn.jobstart({ 'git', '-C', git_root, 'check-ignore', '--stdin' }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= '' then
            ignored_files[line] = true
          end
        end
      end
    end,
    on_exit = function(id, _)
      self.active_jobs_count = self.active_jobs_count - 1
      self.job_pool[id] = nil
      callback(ignored_files)
    end,
  })

  if job_id > 0 then
    self.job_pool[job_id] = { dir = dir }
    vim.fn.chansend(job_id, table.concat(file_paths, '\n'))
    vim.fn.chanclose(job_id, 'stdin')
  else
    self.active_jobs_count = self.active_jobs_count - 1
    callback({})
  end
end

---@param dir string
---@param ignored_map table<string, boolean>
function MiniFilesGitignore:cache_results(dir, ignored_map)
  local gitignore_files = self:get_gitignore_files(dir)
  local gitignore_mtimes = {}

  for _, file_path in ipairs(gitignore_files) do
    local stat = uv.fs_stat(file_path)
    gitignore_mtimes[file_path] = stat and stat.mtime.sec or 0
  end

  local current_time = uv.hrtime() / 1e9
  self.cache[dir] = {
    ignored = ignored_map,
    timestamp = current_time,
    gitignore_files = gitignore_mtimes,
    expires_at = current_time + self.config.cache_ttl,
  }

  self:cleanup_cache()
end

---@param dir string
function MiniFilesGitignore:setup_fs_watcher(dir)
  if self.fs_watchers[dir] then
    return
  end

  if vim.tbl_count(self.fs_watchers) > 50 then
    return
  end

  local gitignore_files = self:get_gitignore_files(dir)
  if #gitignore_files == 0 then
    return
  end

  for _, gitignore_file in ipairs(gitignore_files) do
    if not self.fs_watchers[gitignore_file] then
      local handle = uv.new_fs_event()
      if handle then
        self.fs_watchers[gitignore_file] = handle
        uv.fs_event_start(handle, gitignore_file, {}, function(err, _, _)
          if not err then
            local gitignore_dir = vim.fn.fnamemodify(gitignore_file, ':h')
            for cached_dir, _ in pairs(self.cache) do
              if cached_dir:sub(1, #gitignore_dir) == gitignore_dir then
                self.cache[cached_dir] = nil
              end
            end

            vim.schedule(function()
              local minifiles = require('mini.files')
              minifiles.refresh({
                content = {
                  sort = self.current_sort,
                  filter = self.current_filter,
                },
              })
            end)
          end
        end)
      end
    end
  end
end

---@param parent_dir string
---@param depth integer
function MiniFilesGitignore:prefetch_subdirectories(parent_dir, depth)
  if depth <= 0 or depth > self.config.prefetch_depth then
    return
  end

  if self.active_jobs_count >= self.config.max_concurrent_jobs then
    return
  end

  local handle = uv.fs_scandir(parent_dir)
  if not handle then
    return
  end

  local subdirs = {}
  while true do
    local name, type = uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if type == 'directory' and not name:match('^%.') then
      table.insert(subdirs, parent_dir .. '/' .. name)
    end
  end

  for _, subdir in ipairs(subdirs) do
    if not self:is_cache_valid(subdir) then
      vim.schedule(function()
        local files = {}
        local sub_handle = uv.fs_scandir(subdir)
        if sub_handle then
          while true do
            local sub_name, _ = uv.fs_scandir_next(sub_handle)
            if not sub_name then
              break
            end
            table.insert(files, subdir .. '/' .. sub_name)
          end
          if #files > 0 then
            self:process_files_async(subdir, files, function(ignored_map)
              self:cache_results(subdir, ignored_map)
              self:prefetch_subdirectories(subdir, depth - 1)
            end, true)
          end
        end
      end)
    end
  end
end

---@param fs_entries table[]
---@return table[]
function MiniFilesGitignore:sort_entries(fs_entries)
  if self.state then
    return require('mini.files').default_sort(fs_entries)
  end

  if #fs_entries == 0 then
    return fs_entries
  end

  local dirs_to_process = {}
  local dirs_files = {}

  for _, entry in ipairs(fs_entries) do
    local dir = vim.fn.fnamemodify(entry.path, ':h')
    if not dirs_files[dir] then
      dirs_files[dir] = {}
      if not self:is_cache_valid(dir) then
        table.insert(dirs_to_process, dir)
      end
    end
    table.insert(dirs_files[dir], entry.path)
  end

  for _, dir in ipairs(dirs_to_process) do
    local files = dirs_files[dir]
    self:setup_fs_watcher(dir)

    if #files <= self.config.sync_threshold then
      local ignored_map = self:process_files_sync(dir, files)
      self:cache_results(dir, ignored_map)
    else
      self:process_files_async(dir, files, function(ignored_map)
        self:cache_results(dir, ignored_map)
        vim.schedule(function()
          require('mini.files').refresh({
            content = {
              sort = self.current_sort,
              filter = self.current_filter,
            },
          })
        end)
      end, false)
    end

    self:prefetch_subdirectories(dir, self.config.prefetch_depth)
  end

  local filtered_entries = vim.tbl_filter(function(entry)
    local dir = vim.fn.fnamemodify(entry.path, ':h')
    return not self:is_file_ignored(dir, entry.path)
  end, fs_entries)

  return require('mini.files').default_sort(filtered_entries)
end

function MiniFilesGitignore:toggle_filtering()
  local minifiles = require('mini.files')
  self.state = not self.state

  if self.state then
    self.current_sort = minifiles.default_sort
    self.current_filter = minifiles.default_filter
  else
    self.current_sort = self.initial_sort
    self.current_filter = self.initial_filter
  end

  self:force_refresh()
end

function MiniFilesGitignore:force_refresh()
  local function refresh_with_dummy_filter(char)
    require('mini.files').refresh({
      content = {
        filter = function(fs_entry)
          return not vim.startswith(fs_entry.name, char)
        end,
      },
    })
  end

  refresh_with_dummy_filter(';')
  refresh_with_dummy_filter('.')

  require('mini.files').refresh({
    content = {
      sort = self.current_sort,
      filter = self.current_filter,
    },
  })
end

function MiniFilesGitignore:cleanup()
  for _, handle in pairs(self.fs_watchers) do
    if handle and not handle:is_closing() then
      handle:close()
    end
  end
  self.fs_watchers = {}

  for job_id, _ in pairs(self.job_pool) do
    pcall(vim.fn.jobstop, job_id)
  end
  self.job_pool = {}
  self.cache = {}
end

return MiniFilesGitignore
