require('my.settings')
require('my.plugins')

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

-- set up UI tweaks on load
require('my.utils.lsp').apply_ui_tweaks()
