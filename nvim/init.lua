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

vim.api.nvim_create_user_command('H', function()
  vim.cmd.help(vim.fn.expand('<cword>'))
end, { desc = 'Help for cursorword' })
vim.api.nvim_create_user_command('Filepath', function()
  require('my.utils.clipboard').copy(
    vim.fn.simplify(require('my.utils.path').relative(vim.fn.expand('%') --[[@as string]]))
  )
end, { desc = 'Copy relateive filepath' })

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

-- if I'm editing my nvim config, make sure I'm `cd`d into `nvim`
vim.api.nvim_create_autocmd('BufEnter', {
  once = true,
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if
      string.find(bufname, '/git/dotfiles/nvim') and not vim.endswith(vim.loop.cwd()--[[@as string]], '/nvim')
    then
      vim.cmd.cd('./nvim')
      vim.schedule(vim.cmd.e)
    end
  end,
})

-- open files to last location
vim.api.nvim_create_autocmd('BufReadPost', {
  command = [[if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif]],
})

-- custom URL handling to open GitHub shorthands
local open = vim.ui.open
vim.ui.open = function(uri) ---@diagnostic disable-line: duplicate-set-field
  -- GitHub shorthand pattern, e.g. mrjones2014/dotfiles
  if not string.match(uri, '[a-z]*://[^ >,;]*') and string.match(uri, '[%w%p\\-]*/[%w%p\\-]*') then
    uri = string.format('https://github.com/%s', uri)
  elseif
    vim.api.nvim_get_option_value('filetype', { buf = 0 }) == 'rust'
    and not string.match(uri, '^https?://[%w-_%.%?%.:/%+=&]+')
  then
    -- if the cursorword is not a URL, see if we can open the docs page with rustaceanvim
    vim.cmd.RustLsp('openDocs')
    return
  end

  open(uri)
end

-- set up UI tweaks on load
require('my.utils.lsp').apply_ui_tweaks()
