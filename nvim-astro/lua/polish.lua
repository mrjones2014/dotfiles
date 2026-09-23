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
