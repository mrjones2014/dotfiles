-- Runs last in the setup process.

-- OSC52 clipboard so yanks work over SSH
-- see: https://github.com/neovim/neovim/discussions/28010#discussioncomment-9877494
if vim.env.SSH_TTY ~= nil and vim.env.SSH_TTY ~= '' then
  local function paste()
    return {
      vim.fn.split(vim.fn.getreg(''), '\n'),
      vim.fn.getregtype(''),
    }
  end
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = paste,
      ['*'] = paste,
    },
  }
end

-- open GitHub shorthands (e.g. `mrjones2014/dotfiles`) with `gx`
local open = vim.ui.open
vim.ui.open = function(uri) ---@diagnostic disable-line: duplicate-set-field
  if not string.match(uri, '[a-z]*://[^ >,;]*') and string.match(uri, '[%w%p\\-]*/[%w%p\\-]*') then
    uri = string.format('https://github.com/%s', uri)
  end
  return open(uri)
end

-- make `nvim ./some/dir/` act like `cd ./some/dir/ && nvim`
if vim.fn.argc(-1) == 1 then
  local arg = vim.fn.argv(0) --[[@as string]]
  if arg ~= '' and vim.fn.isdirectory(arg) == 1 then
    vim.cmd.cd(arg)
    vim.cmd('silent! %argdelete')
    vim.api.nvim_create_autocmd('VimEnter', {
      once = true,
      nested = true,
      desc = 'Drop the directory buffer so the dashboard can open',
      callback = function()
        local buf = vim.api.nvim_get_current_buf()
        local name = vim.api.nvim_buf_get_name(buf)
        if name == '' or vim.fn.isdirectory(name) == 0 then
          return
        end
        vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(false, true))
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
        pcall(function()
          require('snacks.dashboard').open()
        end)
      end,
    })
  end
end
