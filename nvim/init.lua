-- use Neovim's experimental Lua module loader that does byte-caching of Lua modules
vim.loader.enable()
---Debug Lua stuff and print a nice debug message via `vim.inspect`.
---@param ... any
_G.dbg = function(...)
  local info = debug.getinfo(2, 'S')
  local source = info.source:sub(2)
  source = vim.loop.fs_realpath(source) or source
  source = vim.fn.fnamemodify(source, ':~:.') .. ':' .. info.linedefined
  local what = { ... }
  if vim.islist(what) and vim.tbl_count(what) <= 1 then
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

require('my.settings')
require('my.plugins')

vim.api.nvim_create_autocmd('UiEnter', {
  callback = function()
    local bufs = vim.api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
      local bufname = vim.api.nvim_buf_get_name(buf)
      if #bufs == 1 and vim.fn.isdirectory(bufname) ~= 0 then
        -- if opened to a directory, cd to the directory
        vim.cmd.cd(bufname)
        break
      end

      if #bufname ~= 0 then
        return
      end
    end
  end,
  once = true,
})

-- custom URL handling to open GitHub shorthands
local open = vim.ui.open
vim.ui.open = function(uri) ---@diagnostic disable-line: duplicate-set-field
  -- GitHub shorthand pattern, e.g. mrjones2014/dotfiles
  if not string.match(uri, '[a-z]*://[^ >,;]*') and string.match(uri, '[%w%p\\-]*/[%w%p\\-]*') then
    uri = string.format('https://github.com/%s', uri)
  end
  open(uri)
end

-- set up UI tweaks on load
require('my.utils.lsp').apply_ui_tweaks()
