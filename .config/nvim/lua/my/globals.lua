-- Global helper functions

---Debug Lua stuff and print a nice debug message via `vim.inspect`.
---@param ... any
_G.p = function(...)
  local info = debug.getinfo(2, 'S')
  local source = info.source:sub(2)
  source = vim.loop.fs_realpath(source) or source
  source = vim.fn.fnamemodify(source, ':~:.') .. ':' .. info.linedefined
  local what = { ... }
  if vim.tbl_islist(what) and vim.tbl_count(what) <= 1 then
    what = what[1]
  end
  local msg = vim.inspect(vim.deepcopy(what))
  require('notify').notify(msg, vim.log.levels.INFO, {
    title = 'Debug: ' .. source,
    on_open = function(win)
      vim.wo[win].conceallevel = 3
      vim.wo[win].concealcursor = ''
      vim.wo[win].spell = false
      local buf = vim.api.nvim_win_get_buf(win)
      vim.treesitter.start(buf, 'lua')
    end,
  })
end

--- A collection of filesystem path related utils
_G.Path = {
  ---Join two or more paths together
  ---@param ... string
  ---@return string
  join = function(...)
    return vim.fn.simplify(table.concat({ ... }, '/'))
  end,

  ---Get path relative to current working directory,
  ---replacing `$HOME` with `~` if applicable.
  ---@param path string
  ---@return string
  relative = function(path)
    return vim.fn.fnamemodify(path, ':~:.')
  end,
}

---Utils for copying to clipboard
_G.Clipboard = {
  ---Copy string to system clipboard
  ---@param str string
  copy = function(str)
    if vim.fn.has('macunix') then
      vim.fn.jobstart(string.format('echo -n %q | pbcopy', str), { detach = true })
    else
      vim.fn.jobstart(string.format('echo -n %q | xclip -sel clip', str), { detach = true })
    end
  end,
}

---Insert multiple items to a table at once.
---@generic T
---@param tbl T[]
---@param ... T
table.insert_all = function(tbl, ...)
  local items = { ... }
  for _, item in ipairs(items) do
    table.insert(tbl, item)
  end
end

---Join two or more lists together
---@param ... table
---@return table
table.join_lists = function(...)
  local lists = { ... }
  local result = {}
  for _, list in ipairs(lists) do
    ---@diagnostic disable-next-line -- optional parameters omitted
    vim.list_extend(result, list)
  end
  return result
end
