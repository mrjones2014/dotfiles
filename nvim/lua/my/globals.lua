-- Global helper functions

---Debug Lua stuff and print a nice debug message via `vim.inspect`.
---@param ... any
_G.dbg = function(...)
  local info = debug.getinfo(2, 'S')
  local source = info.source:sub(2)
  source = vim.loop.fs_realpath(source) or source
  source = vim.fn.fnamemodify(source, ':~:.') .. ':' .. info.linedefined
  local what = { ... }
  if vim.tbl_islist(what) and vim.tbl_count(what) <= 1 then
    what = what[1]
  end
  local msg = vim.inspect(vim.deepcopy(what))
  vim.notify(msg, vim.log.levels.INFO, {
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
    return vim.fn.fnamemodify(path, ':~:.') or path
  end,
}

---Utils for copying to clipboard
_G.Clipboard = {
  ---Copy string to system clipboard
  ---@param str string
  copy = function(str)
    if vim.loop.os_uname().sysname == 'Darwin' then
      vim.fn.jobstart(string.format('echo -n %q | pbcopy', str), { detach = true })
    else
      vim.fn.jobstart(string.format('echo -n %q | xclip -sel clip', str), { detach = true })
    end
  end,
}

_G.TblUtils = {
  ---Join two or more lists together
  ---@param ... table
  ---@return table
  join_lists = function(...)
    local lists = { ... }
    local result = {}
    for _, list in ipairs(lists) do
      vim.list_extend(result, list)
    end
    return result
  end,
}

_G.LSP = {
  ---Set up a callback to run on LSP attach
  ---@param callback fun(client:table,bufnr:number)
  on_attach = function(callback)
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then
          callback(client, bufnr)
        end
      end,
    })
  end,
}

_G.Url = {
  ---Open URL in default browser. Supports GitHub shorthands like `owner/repo`
  ---@param url string
  open = function(url)
    -- plugin paths as interpreted by plugin manager, e.g. mrjones2014/op.nvim
    if not string.match(url, '[a-z]*://[^ >,;]*') and string.match(url, '[%w%p\\-]*/[%w%p\\-]*') then
      url = string.format('https://github.com/%s', url)
    end
    vim.fn.jobstart({ vim.fn.has('macunix') ~= 0 and 'open' or 'xdg-open', url }, { detach = true })
  end,
}
