-- Global helper functions

-- utility for debugging lua stuff
_G.p = function(any)
  print(vim.inspect(any))
end

_G.Path = {
  join = function(...)
    return table.concat({ ... }, '/')
  end,
  relative = function(path)
    return vim.fn.fnamemodify(path, ':~:.')
  end,
}

_G.Clipboard = {
  copy = function(str)
    vim.fn.jobstart(string.format('echo -n %q | pbcopy', str), { detach = true })
  end,
}

table.insert_all = function(tbl, ...)
  local items = { ... }
  for _, item in ipairs(items) do
    table.insert(tbl, item)
  end
end

table.join_lists = function(...)
  local lists = { ... }
  local result = {}
  for _, list in ipairs(lists) do
    vim.list_extend(result, list)
  end
  return result
end

_G.localplugin = function(name)
  local local_repo_name = string.gsub(name, '.*/', '')
  local local_path = string.format('%s/git/github/%s', vim.env.HOME, local_repo_name)
  if vim.fn.isdirectory(local_path) > 0 then
    return local_path
  else
    return name
  end
end
