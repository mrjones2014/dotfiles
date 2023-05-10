vim.opt_local.wrap = true
vim.opt_local.linebreak = true

local win, buf, job_id
local glow = {}

local function close_window()
  vim.api.nvim_win_close(win, true)
end

local function tmp_file()
  local output = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
  if vim.tbl_isempty(output) then
    vim.notify('buffer is empty', vim.log.levels.ERROR)
    return
  end
  local tmp = vim.fn.tempname() .. '.md'
  vim.fn.writefile(output, tmp)
  return tmp
end

local function stop_job(tmp)
  if job_id == nil then
    return
  end
  pcall(vim.fn.system, string.format('rm %s', tmp))
  vim.fn.jobstop(job_id)
end

local function open_window(source_win, source_buf, cmd, tmp, existing_win)
  -- create preview buffer and set local options
  buf = vim.api.nvim_create_buf(false, true)
  win = win or existing_win
  if not win or not vim.api.nvim_win_is_valid(win) then
    vim.cmd('vsp')
    win = vim.api.nvim_get_current_win()
  end
  vim.api.nvim_win_set_buf(win, buf)

  -- options
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'glowpreview')
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_win_set_option(win, 'signcolumn', 'no')
  vim.api.nvim_win_set_option(win, 'number', false)

  -- keymaps
  local keymaps_opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set('n', 'q', close_window, keymaps_opts)
  vim.keymap.set('n', '<Esc>', close_window, keymaps_opts)

  if vim.fn.filereadable(tmp) == 0 then
    tmp = tmp_file()
  end

  local cbs = {
    on_exit = function()
      if tmp ~= nil then
        vim.fn.delete(tmp)
      end
    end,
  }
  job_id = vim.fn.termopen(cmd, cbs)
  vim.api.nvim_set_current_win(source_win)
  vim.api.nvim_create_autocmd({ 'TextChanged' }, {
    callback = function()
      local output = vim.api.nvim_buf_get_lines(source_buf, 0, vim.api.nvim_buf_line_count(0), false)
      if vim.tbl_isempty(output) then
        vim.notify('buffer is empty', vim.log.levels.ERROR)
        return
      end
      vim.fn.writefile(output, tmp)
      vim.schedule(function()
        vim.api.nvim_buf_delete(buf, { force = true })
        open_window(source_win, source_buf, cmd, tmp, win)
      end)
    end,
    buffer = source_buf,
    -- will get re-bound when open_window is called again
    once = true,
  })
end

local function is_md_ft()
  local allowed_fts = { 'markdown', 'markdown.pandoc', 'markdown.gfm', 'wiki', 'vimwiki', 'telekasten' }
  if not vim.tbl_contains(allowed_fts, vim.bo.filetype) then
    return false
  end
  return true
end

local function is_md_ext(ext)
  local allowed_exts = { 'md', 'markdown', 'mkd', 'mkdn', 'mdwn', 'mdown', 'mdtxt', 'mdtext', 'rmd', 'wiki' }
  if not vim.tbl_contains(allowed_exts, string.lower(ext)) then
    return false
  end
  return true
end

local function execute(opts)
  local file, tmp

  if vim.fn.executable('glow') == 0 then
    vim.notify('glow not installed', vim.log.levels.ERROR)
    return
  end

  local filename = opts.fargs[1]

  if filename ~= nil and filename ~= '' then
    -- check file
    file = opts.fargs[1]
    if not vim.fn.filereadable(file) then
      vim.notify('error on reading file', vim.log.levels.ERROR)
      return
    end

    local ext = vim.fn.fnamemodify(file, ':e')
    if not is_md_ext(ext) then
      vim.notify('preview only works on markdown files', vim.log.levels.ERROR)
      return
    end
  else
    if not is_md_ft() then
      vim.notify('preview only works on markdown files', vim.log.levels.ERROR)
      return
    end

    file = tmp_file()
    if file == nil then
      vim.notify('error on preview for current buffer', vim.log.levels.ERROR)
      return
    end
    tmp = file
  end

  stop_job(tmp)

  local cmd_args = { 'glow' }

  table.insert(cmd_args, file)
  local cmd = table.concat(cmd_args, ' ')
  open_window(vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf(), cmd, tmp)
end

glow.execute = function(opts)
  local current_win = vim.fn.win_getid()
  if current_win == win then
    if opts.bang then
      close_window()
    end
    -- do nothing
    return
  end

  execute(opts)
end

vim.api.nvim_create_user_command('Glow', glow.execute, { complete = 'file', nargs = '*', bang = true })

return glow
