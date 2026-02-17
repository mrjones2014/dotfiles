-- use Neovim's experimental Lua module loader that does byte-caching of Lua modules
vim.loader.enable()

---Debug Lua stuff and print a nice debug message via `vim.inspect`.
---@param ... any
_G.dbg = function(...) ---@diagnostic disable-line: duplicate-set-field
  require('snacks.debug').inspect(...)
end

---Debug Lua stuff and print a nice debug message via `vim.inspect`,
---wrapped in `vim.schedule`, so you can call it from fast-events.
_G.dbg_schedule = function(...) ---@diagnostic disable-line: duplicate-set-field
  local args = { ... }
  vim.schedule(function()
    require('snacks.debug').inspect(unpack(args))
  end)
end

require('my.settings')
require('my.plugins')

vim.api.nvim_create_user_command('H', function()
  vim.cmd.help(vim.fn.expand('<cword>'))
end, { desc = 'Help for cursorword' })

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
vim.api.nvim_create_autocmd('BufRead', {
  once = true,
  pattern = '*',
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if string.find(bufname, '/git/dotfiles/nvim') and not vim.endswith(assert(vim.uv.cwd()), '/nvim') then
      vim.cmd.cd('./nvim')
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
